import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/create_sla_policy_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/delete_sla_policy_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/get_sla_policies_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/get_sla_policy_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/update_sla_policy_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/watch_sla_policies_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/presentation/cubits/sla_policies/sla_policies_cubit.dart';
import 'package:o_jogo_da_obra/features/sla_policies/presentation/cubits/sla_policies/sla_policies_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/use_case_mocks.dart';

class MockGetSlaPoliciesUseCase extends Mock implements GetSlaPoliciesUseCase {}

class MockGetSlaPolicyByIdUseCase extends Mock
    implements GetSlaPolicyByIdUseCase {}

class MockCreateSlaPolicyUseCase extends Mock
    implements CreateSlaPolicyUseCase {}

class MockUpdateSlaPolicyUseCase extends Mock
    implements UpdateSlaPolicyUseCase {}

class MockDeleteSlaPolicyUseCase extends Mock
    implements DeleteSlaPolicyUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockGetSlaPoliciesUseCase mockGetSlaPolicies;
  late MockGetSlaPolicyByIdUseCase mockGetSlaPolicyById;
  late MockCreateSlaPolicyUseCase mockCreateSlaPolicy;
  late MockUpdateSlaPolicyUseCase mockUpdateSlaPolicy;
  late MockDeleteSlaPolicyUseCase mockDeleteSlaPolicy;
  late MockWatchSlaPoliciesRealtimeUseCase mockWatchSlaPoliciesRealtime;
  late MockNavigationClient mockNavigationClient;

  late SlaPoliciesCubit cubit;
  late UserProfileEntity tUserProfile;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeSlaPolicyEntity());
    registerFallbackValue(CreateUpdateSlaPolicyRoute());
  });

  setUp(() {
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockGetSlaPolicies = MockGetSlaPoliciesUseCase();
    mockGetSlaPolicyById = MockGetSlaPolicyByIdUseCase();
    mockCreateSlaPolicy = MockCreateSlaPolicyUseCase();
    mockUpdateSlaPolicy = MockUpdateSlaPolicyUseCase();
    mockDeleteSlaPolicy = MockDeleteSlaPolicyUseCase();
    mockWatchSlaPoliciesRealtime = MockWatchSlaPoliciesRealtimeUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = EntityFactory.makeUserProfileEntity();
    when(
      () => mockGetActiveCompanyId.call(),
    ).thenReturn(tUserProfile.companyId);
    when(
      () => mockWatchSlaPoliciesRealtime.call(companyId: any(named: 'companyId')),
    ).thenAnswer((_) => const Stream.empty());

    final useCases = SlaPoliciesCubitUseCases(
      getActiveCompanyId: mockGetActiveCompanyId,
      getSlaPolicies: mockGetSlaPolicies,
      getSlaPolicyById: mockGetSlaPolicyById,
      createSlaPolicy: mockCreateSlaPolicy,
      updateSlaPolicy: mockUpdateSlaPolicy,
      deleteSlaPolicy: mockDeleteSlaPolicy,
      watchSlaPoliciesRealtime: mockWatchSlaPoliciesRealtime,
    );

    cubit = SlaPoliciesCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('SlaPoliciesCubit Tests', () {
    group('loadSlaPolicies', () {
      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'should emit loading and loaded when policies load successfully',
        build: () {
          final tPolicies = EntityFactory.makeSlaPolicyEntityList();
          when(
            () => mockGetSlaPolicies.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tPolicies));
          return cubit;
        },
        act: (cubit) => cubit.loadSlaPolicies(),
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<SlaPoliciesState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.slaPolicies, 'slaPolicies', isNotEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
        verify: (_) {
          verify(
            () => mockGetSlaPolicies.call(tUserProfile.companyId),
          ).called(1);
        },
      );

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'should emit loading and loadingError when loading fails',
        build: () {
          when(
            () => mockGetSlaPolicies.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Failed to fetch'));
          return cubit;
        },
        act: (cubit) => cubit.loadSlaPolicies(),
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<SlaPoliciesState>()
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Failed to fetch'),
        ],
      );
    });

    group('selectSlaPolicy', () {
      final tPolicies = EntityFactory.makeSlaPolicyEntityList();
      final targetPolicy = tPolicies.first;

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'should emit new state with selected policy when id is found',
        seed: () => SlaPoliciesState(slaPolicies: tPolicies),
        build: () => cubit,
        act: (cubit) => cubit.selectSlaPolicy(targetPolicy.id),
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.selectedSlaPolicy,
            'selectedSlaPolicy',
            targetPolicy,
          ),
        ],
      );

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'should emit state with null selectedSlaPolicy when id is null',
        seed: () => SlaPoliciesState(
          slaPolicies: tPolicies,
          selectedSlaPolicy: targetPolicy,
        ),
        build: () => cubit,
        act: (cubit) => cubit.selectSlaPolicy(null),
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.selectedSlaPolicy,
            'selectedSlaPolicy',
            isNull,
          ),
        ],
      );

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'should emit state with null selectedSlaPolicy when id is not found',
        seed: () => SlaPoliciesState(
          slaPolicies: tPolicies,
          selectedSlaPolicy: targetPolicy,
        ),
        build: () => cubit,
        act: (cubit) => cubit.selectSlaPolicy('non-existent-id'),
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.selectedSlaPolicy,
            'selectedSlaPolicy',
            isNull,
          ),
        ],
      );
    });

    group('saveSlaPolicy', () {
      final tPolicy = EntityFactory.makeSlaPolicyEntity();

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'should emit saving and loaded, and reload policies when creation succeeds',
        build: () {
          when(
            () => mockCreateSlaPolicy.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetSlaPolicies.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tPolicy]));
          return cubit;
        },
        act: (cubit) => cubit.saveSlaPolicy(
          name: tPolicy.name,
          targetHours: tPolicy.targetHours,
          appliesTo: tPolicy.appliesTo,
        ),
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(
            () => mockCreateSlaPolicy.call(
              any(
                that: predicate<SlaPolicyEntity>(
                  (p) =>
                      p.name == tPolicy.name &&
                      p.targetHours == tPolicy.targetHours &&
                      p.appliesTo == tPolicy.appliesTo &&
                      p.companyId == tUserProfile.companyId &&
                      p.id.isNotEmpty,
                ),
              ),
            ),
          ).called(1);
          verify(
            () => mockGetSlaPolicies.call(tUserProfile.companyId),
          ).called(1);
        },
      );

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'should emit saving and loaded when updating policy succeeds',
        build: () {
          when(
            () => mockUpdateSlaPolicy.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetSlaPolicies.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tPolicy]));
          return cubit;
        },
        act: (cubit) => cubit.saveSlaPolicy(
          id: tPolicy.id,
          name: tPolicy.name,
          targetHours: tPolicy.targetHours,
          appliesTo: tPolicy.appliesTo,
        ),
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateSlaPolicy.call(any())).called(1);
        },
      );
    });

    group('deleteSlaPolicy', () {
      final tPolicy = EntityFactory.makeSlaPolicyEntity();

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'should emit deleting and loaded when deletion succeeds',
        build: () {
          when(
            () => mockDeleteSlaPolicy.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetSlaPolicies.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.deleteSlaPolicy(tPolicy.id),
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.deleting,
          ),
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteSlaPolicy.call(tPolicy.id)).called(1);
        },
      );
    });

    group('navigateToCreateUpdateSlaPolicy', () {
      final tPolicy = EntityFactory.makeSlaPolicyEntity();

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'should push route and reload SLA policies when push returns true',
        build: () {
          when(
            () => mockNavigationClient.pushRoute<dynamic>(any()),
          ).thenAnswer((_) async => true);
          when(
            () => mockGetSlaPolicies.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tPolicy]));
          return cubit;
        },
        act: (cubit) =>
            cubit.navigateToCreateUpdateSlaPolicy(slaPolicy: tPolicy),
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(
            () => mockNavigationClient.pushRoute<dynamic>(any()),
          ).called(1);
          verify(
            () => mockGetSlaPolicies.call(tUserProfile.companyId),
          ).called(1);
        },
      );

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'should push route without slaPolicy parameter and reload SLA policies when push returns true',
        build: () {
          when(
            () => mockNavigationClient.pushRoute<dynamic>(any()),
          ).thenAnswer((_) async => true);
          when(
            () => mockGetSlaPolicies.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tPolicy]));
          return cubit;
        },
        act: (cubit) => cubit.navigateToCreateUpdateSlaPolicy(),
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(
            () => mockNavigationClient.pushRoute<dynamic>(any()),
          ).called(1);
          verify(
            () => mockGetSlaPolicies.call(tUserProfile.companyId),
          ).called(1);
        },
      );

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'should push route and NOT reload SLA policies when push returns false or null',
        build: () {
          when(
            () => mockNavigationClient.pushRoute<dynamic>(any()),
          ).thenAnswer((_) async => null);
          return cubit;
        },
        act: (cubit) => cubit.navigateToCreateUpdateSlaPolicy(),
        expect: () => <SlaPoliciesState>[],
        verify: (_) {
          verify(
            () => mockNavigationClient.pushRoute<dynamic>(any()),
          ).called(1);
          verifyNever(() => mockGetSlaPolicies.call(any()));
        },
      );
    });

    group('Realtime Events', () {
      final tInitialPolicy = EntityFactory.makeSlaPolicyEntity();
      final tNewPolicy = EntityFactory.makeSlaPolicyEntity();

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'prepends new policy on insert event',
        build: () {
          final streamController =
              StreamController<RealtimeEvent<SlaPolicyEntity>>();
          when(
            () => mockWatchSlaPoliciesRealtime.call(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => streamController.stream);

          final testCubit = SlaPoliciesCubit(
            useCases: SlaPoliciesCubitUseCases(
              getActiveCompanyId: mockGetActiveCompanyId,
              getSlaPolicies: mockGetSlaPolicies,
              getSlaPolicyById: mockGetSlaPolicyById,
              createSlaPolicy: mockCreateSlaPolicy,
              updateSlaPolicy: mockUpdateSlaPolicy,
              deleteSlaPolicy: mockDeleteSlaPolicy,
              watchSlaPoliciesRealtime: mockWatchSlaPoliciesRealtime,
            ),
          );

          testCubit.emit(
            testCubit.state.copyWith(
              status: StateStatus.loaded,
              slaPolicies: [tInitialPolicy],
            ),
          );

          streamController.add(
            RealtimeEvent<SlaPolicyEntity>(
              eventType: RealtimeEventType.insert,
              id: tNewPolicy.id,
              companyId: tUserProfile.companyId,
              entity: tNewPolicy,
            ),
          );

          return testCubit;
        },
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.slaPolicies,
            'slaPolicies',
            [tNewPolicy, tInitialPolicy],
          ),
        ],
      );

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'updates existing policy in-place on update event',
        build: () {
          final streamController =
              StreamController<RealtimeEvent<SlaPolicyEntity>>();
          when(
            () => mockWatchSlaPoliciesRealtime.call(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => streamController.stream);

          final testCubit = SlaPoliciesCubit(
            useCases: SlaPoliciesCubitUseCases(
              getActiveCompanyId: mockGetActiveCompanyId,
              getSlaPolicies: mockGetSlaPolicies,
              getSlaPolicyById: mockGetSlaPolicyById,
              createSlaPolicy: mockCreateSlaPolicy,
              updateSlaPolicy: mockUpdateSlaPolicy,
              deleteSlaPolicy: mockDeleteSlaPolicy,
              watchSlaPoliciesRealtime: mockWatchSlaPoliciesRealtime,
            ),
          );

          testCubit.emit(
            testCubit.state.copyWith(
              status: StateStatus.loaded,
              slaPolicies: [tInitialPolicy],
            ),
          );

          final updatedPolicy = tInitialPolicy.copyWith(name: 'Updated Policy');

          streamController.add(
            RealtimeEvent<SlaPolicyEntity>(
              eventType: RealtimeEventType.update,
              id: tInitialPolicy.id,
              companyId: tUserProfile.companyId,
              entity: updatedPolicy,
            ),
          );

          return testCubit;
        },
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.slaPolicies.first.name,
            'policy name',
            'Updated Policy',
          ),
        ],
      );

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'removes policy on delete event',
        build: () {
          final streamController =
              StreamController<RealtimeEvent<SlaPolicyEntity>>();
          when(
            () => mockWatchSlaPoliciesRealtime.call(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => streamController.stream);

          final testCubit = SlaPoliciesCubit(
            useCases: SlaPoliciesCubitUseCases(
              getActiveCompanyId: mockGetActiveCompanyId,
              getSlaPolicies: mockGetSlaPolicies,
              getSlaPolicyById: mockGetSlaPolicyById,
              createSlaPolicy: mockCreateSlaPolicy,
              updateSlaPolicy: mockUpdateSlaPolicy,
              deleteSlaPolicy: mockDeleteSlaPolicy,
              watchSlaPoliciesRealtime: mockWatchSlaPoliciesRealtime,
            ),
          );

          testCubit.emit(
            testCubit.state.copyWith(
              status: StateStatus.loaded,
              slaPolicies: [tInitialPolicy],
            ),
          );

          streamController.add(
            RealtimeEvent<SlaPolicyEntity>(
              eventType: RealtimeEventType.delete,
              id: tInitialPolicy.id,
              companyId: tUserProfile.companyId,
              entity: null,
            ),
          );

          return testCubit;
        },
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.slaPolicies,
            'slaPolicies',
            isEmpty,
          ),
        ],
      );
    });
  });
}
