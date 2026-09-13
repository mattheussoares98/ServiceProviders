import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/work_order_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late MockSupabaseRealtimeClient mockRealtime;
  late WorkOrderObservationsRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<SupabaseFilter>[]);
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    mockRealtime = MockSupabaseRealtimeClient();
    dataSource = WorkOrderObservationsRemoteDataSourceImpl(
      database: mockDatabase,
      realtimeClient: mockRealtime,
    );
  });

  final tObservationEntity = WorkOrderFactory.makeWorkOrderObservationEntity();
  final tObservationModel = WorkOrderObservationModel.fromEntity(
    tObservationEntity,
  );

  group('getObservations', () {
    test(
      'should return SuccessState with list of observations when successful',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            columns: any(named: 'columns'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tObservationModel.toJson()]);

        final result = await dataSource.getObservations(
          tObservationEntity.workOrderId,
        );

        expect(result, isA<SuccessState<List<WorkOrderObservationModel>>>());
        expect(
          (result as SuccessState<List<WorkOrderObservationModel>>)
              .data!
              .first
              .id,
          tObservationEntity.id,
        );
      },
    );

    test('should return FailureState when database call fails', () async {
      when(
        () => mockDatabase.selectList(
          table: any(named: 'table'),
          columns: any(named: 'columns'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('Database error'));

      final result = await dataSource.getObservations(
        tObservationEntity.workOrderId,
      );

      expect(result, isA<FailureState<List<WorkOrderObservationModel>>>());
    });
  });

  group('getObservationsByWorkOrderIds', () {
    test(
      'should return empty list immediately when workOrderIds is empty',
      () async {
        final result = await dataSource.getObservationsByWorkOrderIds([]);
        expect(result, isA<SuccessState<List<WorkOrderObservationModel>>>());
        expect(result.data, isEmpty);
        verifyZeroInteractions(mockDatabase);
      },
    );

    test(
      'should return SuccessState with list of observations when query succeeds',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            columns: any(named: 'columns'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tObservationModel.toJson()]);

        final result = await dataSource.getObservationsByWorkOrderIds([
          tObservationEntity.workOrderId,
        ]);

        expect(result, isA<SuccessState<List<WorkOrderObservationModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, tObservationEntity.id);
      },
    );

    test('should add updated_at filter when since is provided', () async {
      final tSince = DateTime.utc(2026, 2);
      when(
        () => mockDatabase.selectList(
          table: any(named: 'table'),
          columns: any(named: 'columns'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tObservationModel.toJson()]);

      final result = await dataSource.getObservationsByWorkOrderIds([
        tObservationEntity.workOrderId,
      ], since: tSince);

      expect(result, isA<SuccessState<List<WorkOrderObservationModel>>>());
      verify(
        () => mockDatabase.selectList(
          table: 'work_order_observations',
          columns: any(named: 'columns'),
          filters: any(
            named: 'filters',
            that: contains(
              SupabaseFilter.gt('updated_at', tSince.toIso8601String()),
            ),
          ),
        ),
      ).called(1);
    });

    test('should return FailureState when database call fails', () async {
      when(
        () => mockDatabase.selectList(
          table: any(named: 'table'),
          columns: any(named: 'columns'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('Database error'));

      final result = await dataSource.getObservationsByWorkOrderIds([
        tObservationEntity.workOrderId,
      ]);

      expect(result, isA<FailureState<List<WorkOrderObservationModel>>>());
    });
  });

  group('watchObservationsRealtime', () {
    test('streams changes with work_order_id filter', () {
      when(
        () => mockRealtime.streamTableChanges(
          table: any(named: 'table'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) => const Stream.empty());

      dataSource.watchObservationsRealtime(
        workOrderId: tObservationEntity.workOrderId,
      );

      verify(
        () => mockRealtime.streamTableChanges(
          table: 'work_order_observations',
          filter: any(
            named: 'filter',
            that: isA<PostgresChangeFilter>()
                .having((f) => f.column, 'column', 'work_order_id')
                .having(
                  (f) => f.value,
                  'value',
                  tObservationEntity.workOrderId,
                ),
          ),
        ),
      ).called(1);
    });
  });

  group('createObservation', () {
    test(
      'should return SuccessState with created observation model when successful',
      () async {
        when(
          () => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
            columns: any(named: 'columns'),
          ),
        ).thenAnswer((_) async => [tObservationModel.toJson()]);

        final result = await dataSource.createObservation(tObservationModel);

        expect(result, isA<SuccessState<WorkOrderObservationModel>>());
        expect(
          (result as SuccessState<WorkOrderObservationModel>).data!.id,
          tObservationEntity.id,
        );
      },
    );

    test('should return FailureState when insert fails', () async {
      when(
        () => mockDatabase.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
          columns: any(named: 'columns'),
        ),
      ).thenThrow(Exception('Insert error'));

      final result = await dataSource.createObservation(tObservationModel);

      expect(result, isA<FailureState<WorkOrderObservationModel>>());
    });
  });

  group('deleteObservation', () {
    test('should return SuccessState<bool> when update succeeds', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tObservationModel.toJson()]);

      final result = await dataSource.deleteObservation(tObservationEntity.id);

      expect(result, isA<SuccessState<bool>>());
      expect((result as SuccessState<bool>).data, true);
    });

    test('should return FailureState when delete update fails', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('Update error'));

      final result = await dataSource.deleteObservation(tObservationEntity.id);

      expect(result, isA<FailureState<bool>>());
    });
  });
}
