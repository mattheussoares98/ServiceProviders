import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_session_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/work_order_observations_use_cases.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_state.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';

class MockGetWorkOrderObservationsUseCase extends Mock
    implements GetWorkOrderObservationsUseCase {}

class MockCreateWorkOrderObservationUseCase extends Mock
    implements CreateWorkOrderObservationUseCase {}

class MockDeleteWorkOrderObservationUseCase extends Mock
    implements DeleteWorkOrderObservationUseCase {}

class MockGetSelectedModeUseCase extends Mock
    implements GetSelectedModeUseCase {}

class MockGetSessionProviderProfileUseCase extends Mock
    implements GetSessionProviderProfileUseCase {}

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

void main() {
  late MockGetWorkOrderObservationsUseCase getUseCase;
  late MockCreateWorkOrderObservationUseCase createUseCase;
  late MockDeleteWorkOrderObservationUseCase deleteUseCase;
  late MockGetSelectedModeUseCase mockGetSelectedMode;
  late MockGetSessionProviderProfileUseCase mockGetProviderProfile;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late WorkOrderObservationsCubitUseCases cubitUseCases;
  late MockNavigationClient mockNavigationClient;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeWorkOrderObservationEntity());
  });

  setUp(() {
    getUseCase = MockGetWorkOrderObservationsUseCase();
    createUseCase = MockCreateWorkOrderObservationUseCase();
    deleteUseCase = MockDeleteWorkOrderObservationUseCase();
    mockGetSelectedMode = MockGetSelectedModeUseCase();
    mockGetProviderProfile = MockGetSessionProviderProfileUseCase();
    when(() => mockGetSelectedMode.call()).thenReturn(AppMode.internal.name);
    mockGetSessionUser = MockGetSessionUserUseCase();
    cubitUseCases = WorkOrderObservationsCubitUseCases(
      getObservations: getUseCase,
      createObservation: createUseCase,
      deleteObservation: deleteUseCase,
      getSessionUser: mockGetSessionUser,
      getSelectedMode: mockGetSelectedMode,
      getSessionProviderProfile: mockGetProviderProfile,
    );
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);
  });

  tearDown(GetIt.I.reset);

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
        DataStatus.loading,
      ),
      isA<WorkOrderObservationsState>()
          .having((s) => s.status, 'status', DataStatus.loaded)
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
        DataStatus.loading,
      ),
      isA<WorkOrderObservationsState>()
          .having((s) => s.status, 'status', DataStatus.loadingError)
          .having((s) => s.errorMessage, 'errorMessage', 'Erro ao carregar'),
    ],
  );

  final tObs = EntityFactory.makeWorkOrderObservationEntity();

  blocTest<WorkOrderObservationsCubit, WorkOrderObservationsState>(
    'emits [saving, loaded] when createObservation succeeds',
    build: () {
      final createdObs = EntityFactory.makeWorkOrderObservationEntity();
      when(
        () => mockGetSessionUser.call(),
      ).thenReturn(EntityFactory.makeUserProfileEntity());
      when(
        () => createUseCase.call(any()),
      ).thenAnswer((_) async => SuccessState(data: createdObs));
      return WorkOrderObservationsCubit(useCases: cubitUseCases);
    },
    seed: () => WorkOrderObservationsState(
      status: DataStatus.loaded,
      observations: [tObs],
    ),
    act: (cubit) => cubit.createObservation(
      workOrder: EntityFactory.makeWorkOrderEntity(),
      content: faker.lorem.sentence(),
    ),
    expect: () => [
      isA<WorkOrderObservationsState>().having(
        (s) => s.sections[WorkOrderObservationsSections.saveObservation],
        'sections[saveObservation]',
        SectionStatus.running,
      ),
      isA<WorkOrderObservationsState>()
          .having(
            (s) => s.sections[WorkOrderObservationsSections.saveObservation],
            'sections[saveObservation]',
            SectionStatus.success,
          )
          .having((s) => s.observations.length, 'observations length', 2),
    ],
  );

  test(
    'authors through the provider profile and the work order tenant in provider mode',
    () async {
      final workOrder = EntityFactory.makeWorkOrderEntity();
      final profile = EntityFactory.makeServiceProviderProfileEntity().copyWith(
        serviceProviderCompanyId: workOrder.serviceProviderCompanyId,
      );

      when(() => mockGetSelectedMode.call()).thenReturn(AppMode.provider.name);
      when(
        () => mockGetSessionUser.call(),
      ).thenReturn(EntityFactory.makeUserProfileEntity());
      when(
        () => mockGetProviderProfile.call(any()),
      ).thenAnswer((_) async => SuccessState(data: profile));
      when(() => createUseCase.call(any())).thenAnswer(
        (inv) async => SuccessState(
          data: inv.positionalArguments.first as WorkOrderObservationEntity,
        ),
      );

      final cubit = WorkOrderObservationsCubit(useCases: cubitUseCases);
      final success = await cubit.createObservation(
        workOrder: workOrder,
        content: faker.lorem.sentence(),
      );

      expect(success, isTrue);
      final sent =
          verify(() => createUseCase.call(captureAny())).captured.last
              as WorkOrderObservationEntity;
      // author_id would violate the user_profiles foreign key for a provider.
      expect(sent.authorId, isNull);
      expect(sent.authorProviderProfileId, profile.id);
      expect(sent.authorName, profile.name);
      // The tenant is the contracting company, not the provider's employer.
      expect(sent.companyId, workOrder.companyId);
      await cubit.close();
    },
  );

  test(
    'fails cleanly in provider mode when no provider profile exists',
    () async {
      when(() => mockGetSelectedMode.call()).thenReturn(AppMode.provider.name);
      when(
        () => mockGetSessionUser.call(),
      ).thenReturn(EntityFactory.makeUserProfileEntity());
      when(() => mockGetProviderProfile.call(any())).thenAnswer(
        (_) async => FailureState<ServiceProviderProfileEntity>(
          message: 'Perfil de prestador não encontrado.',
        ),
      );

      final cubit = WorkOrderObservationsCubit(useCases: cubitUseCases);
      final success = await cubit.createObservation(
        workOrder: EntityFactory.makeWorkOrderEntity(),
        content: faker.lorem.sentence(),
      );

      expect(success, isFalse);
      expect(
        cubit.state.sections[WorkOrderObservationsSections.saveObservation],
        SectionStatus.error,
      );
      verifyNever(() => createUseCase.call(any()));
      await cubit.close();
    },
  );

  test('authors as the internal user in internal mode', () async {
    final user = EntityFactory.makeUserProfileEntity();
    final workOrder = EntityFactory.makeWorkOrderEntity();
    when(() => mockGetSelectedMode.call()).thenReturn(AppMode.internal.name);
    when(() => mockGetSessionUser.call()).thenReturn(user);
    when(() => createUseCase.call(any())).thenAnswer(
      (inv) async => SuccessState(
        data: inv.positionalArguments.first as WorkOrderObservationEntity,
      ),
    );

    final cubit = WorkOrderObservationsCubit(useCases: cubitUseCases);
    await cubit.createObservation(
      workOrder: workOrder,
      content: faker.lorem.sentence(),
    );

    final sent =
        verify(() => createUseCase.call(captureAny())).captured.last
            as WorkOrderObservationEntity;
    expect(sent.authorId, user.id);
    expect(sent.authorProviderProfileId, isNull);
    expect(sent.companyId, workOrder.companyId);
    verifyNever(() => mockGetProviderProfile.call(any()));
    await cubit.close();
  });

  blocTest<WorkOrderObservationsCubit, WorkOrderObservationsState>(
    'emits [saving, savingError] when createObservation fails',
    build: () {
      final errorMsg = faker.lorem.sentence();
      when(
        () => mockGetSessionUser.call(),
      ).thenReturn(EntityFactory.makeUserProfileEntity());
      when(
        () => createUseCase.call(any()),
      ).thenAnswer((_) async => FailureState(message: errorMsg));
      return WorkOrderObservationsCubit(useCases: cubitUseCases);
    },
    act: (cubit) => cubit.createObservation(
      workOrder: EntityFactory.makeWorkOrderEntity(),
      content: faker.lorem.sentence(),
    ),
    expect: () => [
      isA<WorkOrderObservationsState>().having(
        (s) => s.sections[WorkOrderObservationsSections.saveObservation],
        'sections[saveObservation]',
        SectionStatus.running,
      ),
      isA<WorkOrderObservationsState>().having(
        (s) => s.sections[WorkOrderObservationsSections.saveObservation],
        'sections[saveObservation]',
        SectionStatus.error,
      ),
    ],
  );

  blocTest<WorkOrderObservationsCubit, WorkOrderObservationsState>(
    'emits section loading then loaded when deleteObservation succeeds',
    build: () {
      when(
        () => deleteUseCase.call(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));
      return WorkOrderObservationsCubit(useCases: cubitUseCases);
    },
    seed: () => WorkOrderObservationsState(
      status: DataStatus.loaded,
      observations: [tObs],
    ),
    act: (cubit) => cubit.deleteObservation(tObs.id),
    expect: () => [
      isA<WorkOrderObservationsState>().having(
        (s) => s.sections[WorkOrderObservationsSections.deleteObservation],
        'deleteObservation section',
        SectionStatus.running,
      ),
      isA<WorkOrderObservationsState>()
          .having(
            (s) => s.sections[WorkOrderObservationsSections.deleteObservation],
            'deleteObservation section',
            SectionStatus.success,
          )
          .having((s) => s.observations, 'observations', isEmpty),
    ],
  );

  blocTest<WorkOrderObservationsCubit, WorkOrderObservationsState>(
    'emits section loading then deletingError when deleteObservation fails',
    build: () {
      when(
        () => deleteUseCase.call(any()),
      ).thenAnswer((_) async => FailureState(message: 'Erro ao excluir'));
      return WorkOrderObservationsCubit(useCases: cubitUseCases);
    },
    seed: () => WorkOrderObservationsState(
      status: DataStatus.loaded,
      observations: [tObs],
    ),
    act: (cubit) => cubit.deleteObservation(tObs.id),
    expect: () => [
      isA<WorkOrderObservationsState>().having(
        (s) => s.sections[WorkOrderObservationsSections.deleteObservation],
        'deleteObservation section',
        SectionStatus.running,
      ),
      isA<WorkOrderObservationsState>().having(
        (s) => s.sections[WorkOrderObservationsSections.deleteObservation],
        'deleteObservation section',
        SectionStatus.error,
      ),
    ],
  );
}
