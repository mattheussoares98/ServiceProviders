import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/assets/data/data_sources/assets_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/requests/asset_request_model.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/responses/asset_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockSupabaseDatabaseClient;
  late MockSupabaseRealtimeClient mockSupabaseRealtimeClient;
  late AssetsRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(
      AssetModel.fromEntity(EntityFactory.makeAssetEntity()),
    );
    registerFallbackValue(
      AssetRequestModel.fromEntity(EntityFactory.makeAssetEntity()),
    );
  });

  setUp(() {
    mockSupabaseDatabaseClient = MockSupabaseDatabaseClient();
    mockSupabaseRealtimeClient = MockSupabaseRealtimeClient();
    dataSource = AssetsRemoteDataSourceImpl(
      database: mockSupabaseDatabaseClient,
      realtimeClient: mockSupabaseRealtimeClient,
    );
  });

  final tAssetEntity = EntityFactory.makeAssetEntity();
  final tAssetModel = AssetModel.fromEntity(tAssetEntity);
  final tAssetRequest = AssetRequestModel.fromEntity(tAssetEntity);

  final tCompanyId = faker.guid.guid();
  final tId = faker.guid.guid();

  group('AssetsRemoteDataSourceImpl', () {
    test(
      'should return SuccessState<List<AssetModel>> on selectList success',
      () async {
        when(
          () => mockSupabaseDatabaseClient.selectList(
            table: any(named: 'table'),
            columns: any(named: 'columns'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tAssetModel.toJson()]);

        final result = await dataSource.getAssets(tCompanyId);

        expect(result, isA<SuccessState<List<AssetModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, tAssetModel.id);
        verify(
          () => mockSupabaseDatabaseClient.selectList(
            table: 'assets',
            columns:
                '*, areas!inner(location_id, deleted_at, locations!inner(deleted_at))',
            filters: [
              SupabaseFilter.eq('company_id', tCompanyId),
              SupabaseFilter.isFilter('deleted_at', null),
              SupabaseFilter.isFilter('areas.deleted_at', null),
              SupabaseFilter.isFilter('areas.locations.deleted_at', null),
            ],
          ),
        ).called(1);
      },
    );

    test('should fetch assets by id for provider mode', () async {
      when(
        () => mockSupabaseDatabaseClient.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tAssetModel.toJson()]);

      final result = await dataSource.getAssetsByIds([tAssetModel.id]);

      expect(result, isA<SuccessState<List<AssetModel>>>());
      expect(result.data!.first.id, tAssetModel.id);
      verify(
        () => mockSupabaseDatabaseClient.selectList(
          table: 'assets',
          filters: [
            SupabaseFilter.inList('id', [tAssetModel.id]),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        ),
      ).called(1);
    });

    test('should not query when the asset id list is empty', () async {
      final result = await dataSource.getAssetsByIds([]);

      expect(result, isA<SuccessState<List<AssetModel>>>());
      expect(result.data, isEmpty);
      verifyNever(
        () => mockSupabaseDatabaseClient.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      );
    });

    test('should return FailureState when the by-id query throws', () async {
      when(
        () => mockSupabaseDatabaseClient.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception(faker.lorem.sentence()));

      final result = await dataSource.getAssetsByIds([tAssetModel.id]);

      expect(result, isA<FailureState<List<AssetModel>>>());
    });

    test('should return SuccessState<AssetModel> on selectOne success', () async {
      when(
        () => mockSupabaseDatabaseClient.selectOne(
          table: any(named: 'table'),
          columns: any(named: 'columns'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => tAssetModel.toJson());

      final result = await dataSource.getAssetById(tId);

      expect(result, isA<SuccessState<AssetModel>>());
      expect(result.data!.id, tAssetModel.id);
      verify(
        () => mockSupabaseDatabaseClient.selectOne(
          table: 'assets',
          columns:
              '*, areas!inner(location_id, deleted_at, locations!inner(deleted_at))',
          filters: [
            SupabaseFilter.eq('id', tId),
            SupabaseFilter.isFilter('deleted_at', null),
            SupabaseFilter.isFilter('areas.deleted_at', null),
            SupabaseFilter.isFilter('areas.locations.deleted_at', null),
          ],
        ),
      ).called(1);
    });

    test('should return FailureState when selectOne returns null', () async {
      when(
        () => mockSupabaseDatabaseClient.selectOne(
          table: any(named: 'table'),
          columns: any(named: 'columns'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => null);

      final result = await dataSource.getAssetById(tId);

      expect(result, isA<FailureState<AssetModel>>());
      verify(
        () => mockSupabaseDatabaseClient.selectOne(
          table: 'assets',
          columns:
              '*, areas!inner(location_id, deleted_at, locations!inner(deleted_at))',
          filters: [
            SupabaseFilter.eq('id', tId),
            SupabaseFilter.isFilter('deleted_at', null),
            SupabaseFilter.isFilter('areas.deleted_at', null),
            SupabaseFilter.isFilter('areas.locations.deleted_at', null),
          ],
        ),
      ).called(1);
    });

    test('should return SuccessState<AssetModel> on create', () async {
      when(
        () => mockSupabaseDatabaseClient.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenAnswer((_) async => [tAssetModel.toJson()]);

      final result = await dataSource.createAsset(tAssetRequest);

      expect(result, isA<SuccessState<AssetModel>>());
      expect(result.data!.id, tAssetModel.id);
      verify(
        () => mockSupabaseDatabaseClient.insert(
          table: 'assets',
          values: tAssetRequest.toJson(),
        ),
      ).called(1);
    });

    test('should return SuccessState<AssetModel> on update', () async {
      when(
        () => mockSupabaseDatabaseClient.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tAssetModel.toJson()]);

      final result = await dataSource.updateAsset(tAssetRequest);

      expect(result, isA<SuccessState<AssetModel>>());
      expect(result.data!.id, tAssetModel.id);
      verify(
        () => mockSupabaseDatabaseClient.update(
          table: 'assets',
          values: tAssetRequest.toJson(),
          filters: [SupabaseFilter.eq('id', tAssetRequest.id)],
        ),
      ).called(1);
    });

    test('should return SuccessState<void> on delete', () async {
      when(
        () => mockSupabaseDatabaseClient.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tAssetModel.toJson()]);

      final result = await dataSource.deleteAsset(tAssetModel.id);

      expect(result, isA<SuccessState<void>>());
      verify(
        () => mockSupabaseDatabaseClient.update(
          table: 'assets',
          values: any(named: 'values'),
          filters: [SupabaseFilter.eq('id', tAssetModel.id)],
        ),
      ).called(1);
    });

    test('watchAssetsRealtime streams realtime events', () {
      final payload = PostgresChangePayload(
        eventType: PostgresChangeEvent.insert,
        newRecord: tAssetModel.toJson(),
        oldRecord: {},
        schema: 'public',
        table: 'assets',
        errors: <dynamic>[],
        commitTimestamp: DateTime.now(),
      );

      when(
        () => mockSupabaseRealtimeClient.streamTableChanges(
          table: 'assets',
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) => Stream.value(payload));

      final stream = dataSource.watchAssetsRealtime(companyId: tCompanyId);

      expect(
        stream,
        emits(
          predicate<RealtimeEvent<AssetModel>>((event) {
            return event.eventType == RealtimeEventType.insert &&
                event.id == tAssetModel.id &&
                event.entity?.name == tAssetModel.name;
          }),
        ),
      );
    });
  });
}
