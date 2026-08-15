import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/pause_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_reason_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_request_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late PauseRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<SupabaseFilter>[]);
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    dataSource = PauseRemoteDataSourceImpl(database: mockDatabase);
  });

  final tReasonEntity = EntityFactory.makePauseReasonEntity();
  final tReasonModel = PauseReasonModel.fromEntity(tReasonEntity);

  final tRequestEntity = EntityFactory.makePauseRequestEntity();
  final tRequestModel = PauseRequestModel.fromEntity(tRequestEntity);

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
      'should return SuccessState with list of pause requests when successful',
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
  });

  group('requestPause', () {
    test('should return SuccessState(true) and update work order when successful', () async {
      when(
        () => mockDatabase.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenAnswer((_) async => [tRequestModel.toJson()]);
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
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
      verify(
        () => mockDatabase.update(
          table: 'work_orders',
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).called(1);
    });
  });

  group('reviewPause', () {
    test('should return SuccessState(true) and update pause request when successful', () async {
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
    });
  });

  group('reviewCompletion', () {
    test('should return SuccessState(true) and update work order to completed when approved', () async {
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
    });
  });

  group('cancelPause', () {
    test('should return SuccessState(true) and update work order to in_progress when successful', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tRequestModel.toJson()]);

      final result = await dataSource.cancelPause(
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
    });
  });
}
