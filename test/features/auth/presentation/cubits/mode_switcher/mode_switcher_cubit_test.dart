import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_by_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/external/router_mocks.dart';
import '../../../../../../testing/mocks/factories/service_provider_factory.dart';
import '../../../../../../testing/mocks/factories/user_factory.dart';

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

class MockGetServiceProviderProfilesByAuthUserUseCase extends Mock
    implements GetServiceProviderProfilesByAuthUserUseCase {}

class MockSaveSelectedModeUseCase extends Mock
    implements SaveSelectedModeUseCase {}

class MockGetSelectedModeUseCase extends Mock
    implements GetSelectedModeUseCase {}

final locator = GetIt.I;

void main() {
  late MockNavigationClient mockNavigationClient;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetServiceProviderProfilesByAuthUserUseCase
  mockGetServiceProviderProfilesByAuthUser;
  late MockSaveSelectedModeUseCase mockSaveSelectedMode;
  late MockGetSelectedModeUseCase mockGetSelectedMode;
  late ModeSwitcherCubit cubit;

  setUpAll(() {
    registerFallbackValue(const MockPageRouteInfo());
  });

  setUp(() {
    mockNavigationClient = MockNavigationClient();
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockGetServiceProviderProfilesByAuthUser =
        MockGetServiceProviderProfilesByAuthUserUseCase();
    mockSaveSelectedMode = MockSaveSelectedModeUseCase();
    mockGetSelectedMode = MockGetSelectedModeUseCase();

    locator.registerSingleton<NavigationClient>(mockNavigationClient);

    final useCases = ModeSwitcherCubitUseCases(
      getSessionUser: mockGetSessionUser,
      getServiceProviderProfilesByAuthUser:
          mockGetServiceProviderProfilesByAuthUser,
      saveSelectedMode: mockSaveSelectedMode,
      getSelectedMode: mockGetSelectedMode,
    );

    cubit = ModeSwitcherCubit(useCases: useCases);
  });

  tearDown(locator.reset);

  group('ModeSwitcherCubit', () {
    blocTest<ModeSwitcherCubit, ModeSwitcherState>(
      'checkEligibilityAndLoadMode should set canSwitchMode to true when user has internal and provider profiles',
      build: () {
        final user = UserFactory.makeUserProfileEntity().copyWith(
          companyId: 'company_123',
        );
        when(() => mockGetSessionUser.call()).thenReturn(user);
        when(
          () => mockGetServiceProviderProfilesByAuthUser.call(user.id),
        ).thenAnswer(
          (_) async => SuccessState(
            data: [ServiceProviderFactory.makeServiceProviderProfileEntity()],
          ),
        );
        when(() => mockGetSelectedMode.call()).thenReturn('provider');
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
        verify(() => mockGetSelectedMode.call()).called(1);
      },
    );

    blocTest<ModeSwitcherCubit, ModeSwitcherState>(
      'checkEligibilityAndLoadMode should set canSwitchMode to false when user has no provider profile',
      build: () {
        final user = UserFactory.makeUserProfileEntity().copyWith(
          companyId: 'company_123',
        );
        when(() => mockGetSessionUser.call()).thenReturn(user);
        when(
          () => mockGetServiceProviderProfilesByAuthUser.call(user.id),
        ).thenAnswer((_) async => const SuccessState(data: []));
        when(() => mockGetSelectedMode.call()).thenReturn('internal');
        return cubit;
      },
      act: (cubit) => cubit.checkEligibilityAndLoadMode(),
      expect: () => [const ModeSwitcherState(selectedMode: AppMode.internal)],
    );

    blocTest<ModeSwitcherCubit, ModeSwitcherState>(
      'selectMode should save mode and navigate to HomeRoute when "internal" is selected',
      build: () {
        when(() => mockSaveSelectedMode.call(any())).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.selectMode(AppMode.internal),
      expect: () => [
        isA<ModeSwitcherState>()
            .having(
              (s) => s.sections[ModeSwitcherSections.save],
              'sections[save]',
              const SectionState.running(),
            )
            .having((s) => s.selectedMode, 'selectedMode', AppMode.internal),
        isA<ModeSwitcherState>()
            .having(
              (s) => s.sections[ModeSwitcherSections.save],
              'sections[save]',
              const SectionState.success(),
            )
            .having((s) => s.selectedMode, 'selectedMode', AppMode.internal),
      ],
      verify: (_) {
        verify(() => mockSaveSelectedMode.call('internal')).called(1);
        verify(
          () => mockNavigationClient.replaceAllRoute(const HomeRoute()),
        ).called(1);
      },
    );

    blocTest<ModeSwitcherCubit, ModeSwitcherState>(
      'selectMode should save mode and navigate to ProviderHomeRoute when "provider" is selected',
      build: () {
        when(() => mockSaveSelectedMode.call(any())).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.selectMode(AppMode.provider),
      expect: () => [
        isA<ModeSwitcherState>()
            .having(
              (s) => s.sections[ModeSwitcherSections.save],
              'sections[save]',
              const SectionState.running(),
            )
            .having((s) => s.selectedMode, 'selectedMode', AppMode.provider),
        isA<ModeSwitcherState>()
            .having(
              (s) => s.sections[ModeSwitcherSections.save],
              'sections[save]',
              const SectionState.success(),
            )
            .having((s) => s.selectedMode, 'selectedMode', AppMode.provider),
      ],
      verify: (_) {
        verify(() => mockSaveSelectedMode.call('provider')).called(1);
        verify(
          () => mockNavigationClient.replaceAllRoute(const ProviderHomeRoute()),
        ).called(1);
      },
    );
  });
}
