import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_sla_policy_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_sla_policies_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_sla_policy_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/sla_policies/sla_policies_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/sla_policies/sla_policies_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

class MockGetSlaPoliciesUseCase extends Mock implements GetSlaPoliciesUseCase {}

class MockGetSlaPolicyByIdUseCase extends Mock
    implements GetSlaPolicyByIdUseCase {}

class MockCreateSlaPolicyUseCase extends Mock
    implements CreateSlaPolicyUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetSlaPoliciesUseCase mockGetSlaPolicies;
  late MockGetSlaPolicyByIdUseCase mockGetSlaPolicyById;
  late MockCreateSlaPolicyUseCase mockCreateSlaPolicy;
  late MockNavigationClient mockNavigationClient;

  late SlaPoliciesCubit cubit;
  late UserProfileEntity tUserProfile;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeSlaPolicyEntity());
  });

  setUp(() {
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockGetSlaPolicies = MockGetSlaPoliciesUseCase();
    mockGetSlaPolicyById = MockGetSlaPolicyByIdUseCase();
    mockCreateSlaPolicy = MockCreateSlaPolicyUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = EntityFactory.makeUserProfileEntity();
    when(() => mockGetSessionUser.call()).thenReturn(tUserProfile);

    final useCases = SlaPoliciesCubitUseCases(
      getSessionUser: mockGetSessionUser,
      getSlaPolicies: mockGetSlaPolicies,
      getSlaPolicyById: mockGetSlaPolicyById,
      createSlaPolicy: mockCreateSlaPolicy,
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
        act: (cubit) => cubit.saveSlaPolicy(tPolicy),
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
          verify(() => mockCreateSlaPolicy.call(tPolicy)).called(1);
          verify(
            () => mockGetSlaPolicies.call(tUserProfile.companyId),
          ).called(1);
        },
      );

      blocTest<SlaPoliciesCubit, SlaPoliciesState>(
        'should emit saving and savingError when creation fails',
        build: () {
          when(
            () => mockCreateSlaPolicy.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error creating'));
          return cubit;
        },
        act: (cubit) => cubit.saveSlaPolicy(tPolicy),
        expect: () => [
          isA<SlaPoliciesState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<SlaPoliciesState>()
              .having((s) => s.status, 'status', StateStatus.savingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Error creating'),
        ],
        verify: (_) {
          verify(() => mockCreateSlaPolicy.call(tPolicy)).called(1);
        },
      );
    });
  });
}
