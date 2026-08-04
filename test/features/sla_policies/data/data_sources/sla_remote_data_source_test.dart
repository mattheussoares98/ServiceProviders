import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/data_sources/sla_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/models/responses/sla_policy_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late SlaRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<SupabaseFilter>[]);
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    dataSource = SlaRemoteDataSourceImpl(database: mockDatabase);
  });

  final tSlaPolicyEntity = EntityFactory.makeSlaPolicyEntity();
  final tSlaPolicyModel = SlaPolicyModel.fromEntity(tSlaPolicyEntity);

  group('getSlaPolicies', () {
    test(
      'should return SuccessState with list of SLA policies when successful',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tSlaPolicyModel.toJson()]);

        final result = await dataSource.getSlaPolicies(
          tSlaPolicyEntity.companyId,
        );

        expect(result, isA<SuccessState<List<SlaPolicyModel>>>());
        expect(
          (result as SuccessState<List<SlaPolicyModel>>).data!.first.id,
          tSlaPolicyEntity.id,
        );
        verify(
          () => mockDatabase.selectList(
            table: 'sla_policies',
            filters: any(named: 'filters'),
          ),
        ).called(1);
      },
    );

    test('should return FailureState when call fails', () async {
      when(
        () => mockDatabase.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('DB error'));

      final result = await dataSource.getSlaPolicies(
        tSlaPolicyEntity.companyId,
      );

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('getSlaPolicyById', () {
    test('should return SuccessState with SLA policy when found', () async {
      when(
        () => mockDatabase.selectOne(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => tSlaPolicyModel.toJson());

      final result = await dataSource.getSlaPolicyById(tSlaPolicyEntity.id);

      expect(result, isA<SuccessState<SlaPolicyModel>>());
      expect(
        (result as SuccessState<SlaPolicyModel>).data!.id,
        tSlaPolicyEntity.id,
      );
    });

    test('should return FailureState when SLA policy not found', () async {
      when(
        () => mockDatabase.selectOne(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => null);

      final result = await dataSource.getSlaPolicyById(tSlaPolicyEntity.id);

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('createSlaPolicy', () {
    test(
      'should return SuccessState(true) when insertion is successful',
      () async {
        when(
          () => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tSlaPolicyModel.toJson()]);

        final result = await dataSource.createSlaPolicy(tSlaPolicyModel);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verify(
          () => mockDatabase.insert(
            table: 'sla_policies',
            values: any(named: 'values'),
          ),
        ).called(1);
      },
    );

    test('should return FailureState when insertion fails', () async {
      when(
        () => mockDatabase.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenThrow(Exception('DB error'));

      final result = await dataSource.createSlaPolicy(tSlaPolicyModel);

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('updateSlaPolicy', () {
    test(
      'should return SuccessState(true) when update is successful',
      () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tSlaPolicyModel.toJson()]);

        final result = await dataSource.updateSlaPolicy(tSlaPolicyModel);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verify(
          () => mockDatabase.update(
            table: 'sla_policies',
            values: tSlaPolicyModel.toJson(),
            filters: any(named: 'filters'),
          ),
        ).called(1);
      },
    );

    test('should return FailureState when update fails', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('DB error'));

      final result = await dataSource.updateSlaPolicy(tSlaPolicyModel);

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('deleteSlaPolicy', () {
    test(
      'should return SuccessState(null) when delete (soft delete) is successful',
      () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => []);

        final result = await dataSource.deleteSlaPolicy(tSlaPolicyModel.id);

        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockDatabase.update(
            table: 'sla_policies',
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).called(1);
      },
    );

    test('should return FailureState when delete fails', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('DB error'));

      final result = await dataSource.deleteSlaPolicy(tSlaPolicyModel.id);

      expect(result, isA<FailureState<dynamic>>());
    });
  });
}
