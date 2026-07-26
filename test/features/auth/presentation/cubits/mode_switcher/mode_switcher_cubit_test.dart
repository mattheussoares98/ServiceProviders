import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/external/router_mocks.dart';

final locator = GetIt.I;

void main() {
  late MockLocalStorageClient mockLocalStorageClient;
  late MockNavigationClient mockNavigationClient;
  late ModeSwitcherCubit cubit;

  setUpAll(() {
    registerFallbackValue(const MockPageRouteInfo());
  });

  setUp(() {
    mockLocalStorageClient = MockLocalStorageClient();
    mockNavigationClient = MockNavigationClient();

    locator.registerSingleton<NavigationClient>(mockNavigationClient);

    cubit = ModeSwitcherCubit(localStorageClient: mockLocalStorageClient);
  });

  tearDown(locator.reset);

  group('ModeSwitcherCubit', () {
    blocTest<ModeSwitcherCubit, ModeSwitcherState>(
      'loadCurrentMode should load saved mode from local storage',
      build: () {
        when(
          () => mockLocalStorageClient.getSelectedMode(),
        ).thenReturn('provider');
        return cubit;
      },
      act: (cubit) => cubit.loadCurrentMode(),
      expect: () => [const ModeSwitcherState(selectedMode: AppMode.provider)],
      verify: (_) {
        verify(() => mockLocalStorageClient.getSelectedMode()).called(1);
      },
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

    blocTest<ModeSwitcherCubit, ModeSwitcherState>(
      'selectMode should emit error state when saving fails',
      build: () {
        when(
          () => mockLocalStorageClient.saveSelectedMode(any()),
        ).thenThrow(Exception('Storage error'));
        return cubit;
      },
      act: (cubit) => cubit.selectMode(AppMode.internal),
      expect: () => [
        const ModeSwitcherState(
          status: StateStatus.loading,
          selectedMode: AppMode.internal,
        ),
        const ModeSwitcherState(
          status: StateStatus.savingError,
          selectedMode: AppMode.internal,
          errorMessage: 'Erro ao salvar o modo de acesso.',
        ),
      ],
      verify: (_) {
        verify(
          () => mockLocalStorageClient.saveSelectedMode('internal'),
        ).called(1);
        verifyNever(() => mockNavigationClient.replaceAllRoute(any()));
      },
    );
  });
}
