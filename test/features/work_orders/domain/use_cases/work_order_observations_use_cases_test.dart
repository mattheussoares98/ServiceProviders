import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_order_observations_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/work_order_observations_use_cases.dart';

import '../../../../../testing/mocks/entity_factory.dart';

class MockWorkOrderObservationsRepository extends Mock
    implements WorkOrderObservationsRepository {}

void main() {
  late MockWorkOrderObservationsRepository repository;
  late GetWorkOrderObservationsUseCase getUseCase;
  late CreateWorkOrderObservationUseCase createUseCase;
  late DeleteWorkOrderObservationUseCase deleteUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeWorkOrderObservationEntity());
  });

  setUp(() {
    repository = MockWorkOrderObservationsRepository();
    getUseCase = GetWorkOrderObservationsUseCase(repository);
    createUseCase = CreateWorkOrderObservationUseCase(repository);
    deleteUseCase = DeleteWorkOrderObservationUseCase(repository);
  });

  group('WorkOrderObservations UseCases', () {
    test('GetWorkOrderObservationsUseCase calls repository', () async {
      final list = EntityFactory.makeWorkOrderObservationEntityList();
      when(
        () => repository.getObservations(any()),
      ).thenAnswer((_) async => SuccessState(data: list));

      final result = await getUseCase(faker.guid.guid());

      expect(result, isA<SuccessState<List<WorkOrderObservationEntity>>>());
      verify(() => repository.getObservations(any())).called(1);
    });

    test('CreateWorkOrderObservationUseCase calls repository', () async {
      final entity = EntityFactory.makeWorkOrderObservationEntity();
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
