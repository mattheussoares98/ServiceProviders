import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/pause_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pauses/pause_reason_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pauses/pause_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/work_order_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late MockSupabaseRealtimeClient mockRealtime;
  late PauseRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<SupabaseFilter>[]);
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    mockRealtime = MockSupabaseRealtimeClient();
    dataSource = PauseRemoteDataSourceImpl(
      database: mockDatabase,
      realtimeClient: mockRealtime,
    );
  });

  final tReasonEntity = WorkOrderFactory.makePauseReasonEntity();
  final tReasonModel = PauseReasonModel.fromEntity(tReasonEntity);

  final tRequestEntity = WorkOrderFactory.makePauseRequestEntity();
  final tRequestModel = PauseRequestModel.fromEntity(tRequestEntity);

  group('watchPauseReasonsRealtime', () {
    test('streams changes from pause_reasons table with company filter', () {
      when(
        () => mockRealtime.streamTableChanges(
          table: any(named: 'table'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) => const Stream.empty());

      dataSource.watchPauseReasonsRealtime(companyId: tReasonEntity.companyId);

      verify(
        () => mockRealtime.streamTableChanges(
          table: 'pause_reasons',
          filter: any(
            named: 'filter',
            that: isA<PostgresChangeFilter>()
                .having((f) => f.column, 'column', 'company_id')
                .having((f) => f.value, 'value', tReasonEntity.companyId),
          ),
        ),
      ).called(1);
    });
  });

  group('watchPauseRequestsRealtime', () {
    test(
      'streams changes from work_order_pause_requests table with workOrderId filter',
      () {
        when(
          () => mockRealtime.streamTableChanges(
            table: any(named: 'table'),
            filter: any(named: 'filter'),
          ),
        ).thenAnswer((_) => const Stream.empty());

        dataSource.watchPauseRequestsRealtime(
          workOrderId: tRequestEntity.workOrderId,
        );

        verify(
          () => mockRealtime.streamTableChanges(
            table: 'work_order_pause_requests',
            filter: any(
              named: 'filter',
              that: isA<PostgresChangeFilter>()
                  .having((f) => f.column, 'column', 'work_order_id')
                  .having((f) => f.value, 'value', tRequestEntity.workOrderId),
            ),
          ),
        ).called(1);
      },
    );
  });

  group('getPauseRequestsByWorkOrderIds', () {
    test(
      'returns empty list without calling database when workOrderIds is empty',
      () async {
        final result = await dataSource.getPauseRequestsByWorkOrderIds([]);

        expect(result, isA<SuccessState<List<PauseRequestModel>>>());
        expect(result.data, isEmpty);
        verifyZeroInteractions(mockDatabase);
      },
    );

    test('fetches pause requests for multiple work order ids', () async {
      when(
        () => mockDatabase.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tRequestModel.toJson()]);

      final result = await dataSource.getPauseRequestsByWorkOrderIds([
        tRequestEntity.workOrderId,
      ]);

      expect(result, isA<SuccessState<List<PauseRequestModel>>>());
      expect(result.data?.first.id, tRequestEntity.id);
      verify(
        () => mockDatabase.selectList(
          table: 'work_order_pause_requests',
          filters: [
            SupabaseFilter.inList('work_order_id', [
              tRequestEntity.workOrderId,
            ]),
          ],
        ),
      ).called(1);
    });
  });

  group('getPauseReasons', () {
    test(
      'should return SuccessState with list of pause reasons when successful',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tReasonModel.toJson()]);

        final result = await dataSource.getPauseReasons(
          tReasonEntity.companyId,
        );

        expect(result, isA<SuccessState<List<PauseReasonModel>>>());
        expect(
          (result as SuccessState<List<PauseReasonModel>>).data!.first.id,
          tReasonEntity.id,
        );
      },
    );
  });

  group('getPauseRequests', () {
    test(
      'should return SuccessState with list of pause requests when successful without status filter',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tRequestModel.toJson()]);

        final result = await dataSource.getPauseRequests(
          tRequestEntity.workOrderId,
        );

        expect(result, isA<SuccessState<List<PauseRequestModel>>>());
        expect(
          (result as SuccessState<List<PauseRequestModel>>).data!.first.id,
          tRequestEntity.id,
        );
      },
    );

    test(
      'should return SuccessState with list of pause requests when successful with status filter',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tRequestModel.toJson()]);

        final result = await dataSource.getPauseRequests(
          tRequestEntity.workOrderId,
          status: 'pending',
        );

        expect(result, isA<SuccessState<List<PauseRequestModel>>>());
        expect(
          (result as SuccessState<List<PauseRequestModel>>).data!.first.id,
          tRequestEntity.id,
        );
      },
    );
  });

  group('requestPause', () {
    test(
      'should return SuccessState(true) and insert pause request when successful',
      () async {
        when(
          () => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tRequestModel.toJson()]);

        final result = await dataSource.requestPause(tRequestModel);

        expect(result, const SuccessState(data: true));
        verify(
          () => mockDatabase.insert(
            table: 'work_order_pause_requests',
            values: any(named: 'values'),
          ),
        ).called(1);
      },
    );
  });

  group('reviewPause', () {
    test(
      'should return SuccessState(true) and update pause request when successful',
      () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tRequestModel.toJson()]);

        final result = await dataSource.reviewPause(
          id: tRequestEntity.id,
          workOrderId: tRequestEntity.workOrderId,
          status: 'approved',
          reviewObservation: 'approved observation',
          reviewedById: 'manager-id',
        );

        expect(result, const SuccessState(data: true));
        verify(
          () => mockDatabase.update(
            table: 'work_order_pause_requests',
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).called(1);
        verifyNever(
          () => mockDatabase.update(
            table: 'work_orders',
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        );
      },
    );
  });

  group('reviewCompletion', () {
    test(
      'should return SuccessState(true) and update work order to completed when approved',
      () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tRequestModel.toJson()]);

        final result = await dataSource.reviewCompletion(
          id: tRequestEntity.id,
          workOrderId: tRequestEntity.workOrderId,
          status: 'approved',
          reviewedById: 'manager-id',
          responsibility: 'contractor',
          completionReason: 'done',
        );

        expect(result, const SuccessState(data: true));
        verify(
          () => mockDatabase.update(
            table: 'work_order_pause_requests',
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).called(1);
        verify(
          () => mockDatabase.update(
            table: 'work_orders',
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).called(1);
      },
    );
  });

  group('resumeWork', () {
    test(
      'should return SuccessState(true) and update work order to in_progress when successful',
      () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tRequestModel.toJson()]);

        final result = await dataSource.resumeWork(
          id: tRequestEntity.id,
          workOrderId: tRequestEntity.workOrderId,
          resumedAt: DateTime.now(),
          resumedById: tRequestEntity.resumedById!,
        );

        expect(result, const SuccessState(data: true));
        verify(
          () => mockDatabase.update(
            table: 'work_order_pause_requests',
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).called(1);
        verify(
          () => mockDatabase.update(
            table: 'work_orders',
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).called(1);
      },
    );
  });
}
