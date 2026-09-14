import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_order_observations_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_observations_batch_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/watch_work_order_observations_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/work_order_observations_use_cases.dart';

import '../../../../../testing/mocks/factories/work_order_factory.dart';

class MockWorkOrderObservationsRepository extends Mock
    implements WorkOrderObservationsRepository {}

void main() {
  late MockWorkOrderObservationsRepository repository;
  late GetWorkOrderObservationsUseCase getUseCase;
  late GetWorkOrderObservationsBatchUseCase getBatchUseCase;
  late WatchWorkOrderObservationsRealtimeUseCase watchRealtimeUseCase;
  late CreateWorkOrderObservationUseCase createUseCase;
  late DeleteWorkOrderObservationUseCase deleteUseCase;

  setUpAll(() {
    registerFallbackValue(WorkOrderFactory.makeWorkOrderObservationEntity());
  });

  setUp(() {
    repository = MockWorkOrderObservationsRepository();
    getUseCase = GetWorkOrderObservationsUseCase(repository);
    getBatchUseCase = GetWorkOrderObservationsBatchUseCase(
      repository: repository,
    );
    watchRealtimeUseCase = WatchWorkOrderObservationsRealtimeUseCase(
      repository: repository,
    );
    createUseCase = CreateWorkOrderObservationUseCase(repository);
    deleteUseCase = DeleteWorkOrderObservationUseCase(repository);
  });

  group('WorkOrderObservations UseCases', () {
    test('GetWorkOrderObservationsUseCase calls repository', () async {
      final list = WorkOrderFactory.makeWorkOrderObservationEntityList();
      when(
        () => repository.getObservations(any()),
      ).thenAnswer((_) async => SuccessState(data: list));

      final result = await getUseCase(faker.guid.guid());

      expect(result, isA<SuccessState<List<WorkOrderObservationEntity>>>());
      verify(() => repository.getObservations(any())).called(1);
    });

    test('GetWorkOrderObservationsBatchUseCase calls repository', () async {
      final list = WorkOrderFactory.makeWorkOrderObservationEntityList();
      final ids = [faker.guid.guid(), faker.guid.guid()];
      when(
        () => repository.getObservationsByWorkOrderIds(any()),
      ).thenAnswer((_) async => SuccessState(data: list));

      final result = await getBatchUseCase(
        GetWorkOrderObservationsBatchParams(workOrderIds: ids),
      );

      expect(result, isA<SuccessState<List<WorkOrderObservationEntity>>>());
      verify(() => repository.getObservationsByWorkOrderIds(ids)).called(1);
    });

    test(
      'WatchWorkOrderObservationsRealtimeUseCase calls repository',
      () async {
        final entity = WorkOrderFactory.makeWorkOrderObservationEntity();
        final workOrderId = faker.guid.guid();
        final companyId = faker.guid.guid();
        when(
          () => repository.watchObservationsRealtime(
            companyId: any(named: 'companyId'),
            workOrderId: any(named: 'workOrderId'),
          ),
        ).thenAnswer(
          (_) => Stream.value(
            RealtimeEvent<WorkOrderObservationEntity>(
              eventType: RealtimeEventType.insert,
              id: entity.id,
              companyId: entity.companyId,
              entity: entity,
            ),
          ),
        );

        final stream = watchRealtimeUseCase(
          companyId: companyId,
          workOrderId: workOrderId,
        );
        final event = await stream.first;

        expect(event.id, equals(entity.id));
        verify(
          () => repository.watchObservationsRealtime(
            companyId: companyId,
            workOrderId: workOrderId,
          ),
        ).called(1);
      },
    );

    test('CreateWorkOrderObservationUseCase calls repository', () async {
      final entity = WorkOrderFactory.makeWorkOrderObservationEntity();
      when(
        () => repository.createObservation(any()),
      ).thenAnswer((_) async => SuccessState(data: entity));

      final result = await createUseCase(entity);

      expect(result, isA<SuccessState<WorkOrderObservationEntity>>());
      verify(() => repository.createObservation(any())).called(1);
    });

    test('DeleteWorkOrderObservationUseCase calls repository', () async {
      when(
        () => repository.deleteObservation(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await deleteUseCase(faker.guid.guid());

      expect(result, isA<SuccessState<bool>>());
      verify(() => repository.deleteObservation(any())).called(1);
    });
  });
}
