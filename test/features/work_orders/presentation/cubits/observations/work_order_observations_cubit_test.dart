import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/work_order_observations_use_cases.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_state.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

class MockGetWorkOrderObservationsUseCase extends Mock
    implements GetWorkOrderObservationsUseCase {}

class MockCreateWorkOrderObservationUseCase extends Mock
    implements CreateWorkOrderObservationUseCase {}

class MockDeleteWorkOrderObservationUseCase extends Mock
    implements DeleteWorkOrderObservationUseCase {}

void main() {
  late MockGetWorkOrderObservationsUseCase getUseCase;
  late MockCreateWorkOrderObservationUseCase createUseCase;
  late MockDeleteWorkOrderObservationUseCase deleteUseCase;
  late WorkOrderObservationsCubitUseCases cubitUseCases;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeWorkOrderObservationEntity());
  });

  setUp(() {
    getUseCase = MockGetWorkOrderObservationsUseCase();
    createUseCase = MockCreateWorkOrderObservationUseCase();
    deleteUseCase = MockDeleteWorkOrderObservationUseCase();
    cubitUseCases = WorkOrderObservationsCubitUseCases(
      getObservations: getUseCase,
      createObservation: createUseCase,
      deleteObservation: deleteUseCase,
    );
  });

  blocTest<WorkOrderObservationsCubit, WorkOrderObservationsState>(
    'emits [loading, loaded] when fetchObservations succeeds',
    build: () {
      final list = EntityFactory.makeWorkOrderObservationEntityList();
      when(
        () => getUseCase.call(any()),
      ).thenAnswer((_) async => SuccessState(data: list));
      return WorkOrderObservationsCubit(useCases: cubitUseCases);
    },
    act: (cubit) => cubit.fetchObservations(faker.guid.guid()),
    expect: () => [
      isA<WorkOrderObservationsState>().having(
        (s) => s.status,
        'status',
        StateStatus.loading,
      ),
      isA<WorkOrderObservationsState>()
          .having((s) => s.status, 'status', StateStatus.loaded)
          .having((s) => s.observations.length, 'observations length', 3),
    ],
  );

  blocTest<WorkOrderObservationsCubit, WorkOrderObservationsState>(
    'emits [loading, error] when fetchObservations fails',
    build: () {
      when(
        () => getUseCase.call(any()),
      ).thenAnswer((_) async => FailureState(message: 'Erro ao carregar'));
      return WorkOrderObservationsCubit(useCases: cubitUseCases);
    },
    act: (cubit) => cubit.fetchObservations(faker.guid.guid()),
    expect: () => [
      isA<WorkOrderObservationsState>().having(
        (s) => s.status,
        'status',
        StateStatus.loading,
      ),
      isA<WorkOrderObservationsState>()
          .having((s) => s.status, 'status', StateStatus.loadingError)
          .having((s) => s.errorMessage, 'errorMessage', 'Erro ao carregar'),
    ],
  );
}
