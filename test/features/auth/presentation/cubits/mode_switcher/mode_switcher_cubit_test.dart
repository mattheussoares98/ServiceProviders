import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_service_provider_profiles_by_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/external/router_mocks.dart';

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

class MockGetServiceProviderProfilesByAuthUserUseCase extends Mock
    implements GetServiceProviderProfilesByAuthUserUseCase {}

final locator = GetIt.I;

void main() {
  late MockLocalStorageClient mockLocalStorageClient;
  late MockNavigationClient mockNavigationClient;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetServiceProviderProfilesByAuthUserUseCase
  mockGetServiceProviderProfilesByAuthUser;
  late ModeSwitcherCubit cubit;

  setUpAll(() {
    registerFallbackValue(const MockPageRouteInfo());
  });

  setUp(() {
    mockLocalStorageClient = MockLocalStorageClient();
    mockNavigationClient = MockNavigationClient();
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockGetServiceProviderProfilesByAuthUser =
        MockGetServiceProviderProfilesByAuthUserUseCase();

    locator.registerSingleton<NavigationClient>(mockNavigationClient);

    final useCases = ModeSwitcherCubitUseCases(
      getSessionUser: mockGetSessionUser,
      getServiceProviderProfilesByAuthUser:
          mockGetServiceProviderProfilesByAuthUser,
    );

    cubit = ModeSwitcherCubit(
      localStorageClient: mockLocalStorageClient,
      useCases: useCases,
    );
  });

  tearDown(locator.reset);

  group('ModeSwitcherCubit', () {
    blocTest<ModeSwitcherCubit, ModeSwitcherState>(
      'checkEligibilityAndLoadMode should set canSwitchMode to true when user has internal and provider profiles',
      build: () {
        final user = EntityFactory.makeUserProfileEntity().copyWith(
          companyId: 'company_123',
        );
        when(() => mockGetSessionUser.call()).thenReturn(user);
        when(
          () => mockGetServiceProviderProfilesByAuthUser.call(user.id),
        ).thenAnswer(
          (_) async => SuccessState(
            data: [EntityFactory.makeServiceProviderProfileEntity()],
          ),
        );
        when(
          () => mockLocalStorageClient.getSelectedMode(),
        ).thenReturn('provider');
        return cubit;
      },
      act: (cubit) => cubit.checkEligibilityAndLoadMode(),
      expect: () => [
        const ModeSwitcherState(
          canSwitchMode: true,
          selectedMode: AppMode.provider,
        ),
      ],
      verify: (_) {
        verify(() => mockLocalStorageClient.getSelectedMode()).called(1);
      },
    );

    blocTest<ModeSwitcherCubit, ModeSwitcherState>(
      'checkEligibilityAndLoadMode should set canSwitchMode to false when user has no provider profile',
      build: () {
        final user = EntityFactory.makeUserProfileEntity().copyWith(
          companyId: 'company_123',
        );
        when(() => mockGetSessionUser.call()).thenReturn(user);
        when(
          () => mockGetServiceProviderProfilesByAuthUser.call(user.id),
        ).thenAnswer((_) async => const SuccessState(data: []));
        when(
          () => mockLocalStorageClient.getSelectedMode(),
        ).thenReturn('internal');
        return cubit;
      },
      act: (cubit) => cubit.checkEligibilityAndLoadMode(),
      expect: () => [const ModeSwitcherState(selectedMode: AppMode.internal)],
    );

    blocTest<ModeSwitcherCubit, ModeSwitcherState>(
      'selectMode should save mode and navigate to HomeRoute when "internal" is selected',
      build: () {
        when(
          () => mockLocalStorageClient.saveSelectedMode(any()),
        ).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.selectMode(AppMode.internal),
      expect: () => [
        const ModeSwitcherState(
          status: StateStatus.loading,
          selectedMode: AppMode.internal,
        ),
        const ModeSwitcherState(
          status: StateStatus.loaded,
          selectedMode: AppMode.internal,
        ),
      ],
      verify: (_) {
        verify(
          () => mockLocalStorageClient.saveSelectedMode('internal'),
        ).called(1);
        verify(
          () => mockNavigationClient.replaceAllRoute(const HomeRoute()),
        ).called(1);
      },
    );

    blocTest<ModeSwitcherCubit, ModeSwitcherState>(
      'selectMode should save mode and navigate to ProviderHomeRoute when "provider" is selected',
      build: () {
        when(
          () => mockLocalStorageClient.saveSelectedMode(any()),
        ).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.selectMode(AppMode.provider),
      expect: () => [
        const ModeSwitcherState(
          status: StateStatus.loading,
          selectedMode: AppMode.provider,
        ),
        const ModeSwitcherState(
          status: StateStatus.loaded,
          selectedMode: AppMode.provider,
        ),
      ],
      verify: (_) {
        verify(
          () => mockLocalStorageClient.saveSelectedMode('provider'),
        ).called(1);
        verify(
          () => mockNavigationClient.replaceAllRoute(const ProviderHomeRoute()),
        ).called(1);
      },
    );
  });
}
