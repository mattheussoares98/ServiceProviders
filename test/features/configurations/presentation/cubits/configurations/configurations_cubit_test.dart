import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/entities/configurations_entity.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/clear_app_cache_use_case.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/get_configurations_use_case.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/save_configurations_use_case.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/save_theme_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/cubits/configurations/configurations_cubit.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/cubits/configurations/configurations_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';

class MockSaveConfigurationsUseCase extends Mock
    implements SaveConfigurationsUseCase {}

class MockSaveThemeModeUseCase extends Mock implements SaveThemeModeUseCase {}

class MockGetConfigurationsUseCase extends Mock
    implements GetConfigurationsUseCase {}

class MockClearAppCacheUseCase extends Mock implements ClearAppCacheUseCase {}

void main() {
  late MockGetConfigurationsUseCase mockGetConfigurations;
  late MockSaveConfigurationsUseCase mockSaveConfigurations;
  late MockSaveThemeModeUseCase mockSaveThemeMode;
  late MockClearAppCacheUseCase mockClearAppCache;
  late MockNavigationClient mockNavigationClient;
  late ConfigurationsCubitUseCases useCases;

  setUp(() {
    mockGetConfigurations = MockGetConfigurationsUseCase();
    mockSaveConfigurations = MockSaveConfigurationsUseCase();
    mockSaveThemeMode = MockSaveThemeModeUseCase();
    mockClearAppCache = MockClearAppCacheUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    useCases = ConfigurationsCubitUseCases(
      getConfigurations: mockGetConfigurations,
      saveConfigurations: mockSaveConfigurations,
      saveThemeMode: mockSaveThemeMode,
      clearAppCache: mockClearAppCache,
    );
  });

  tearDown(GetIt.I.reset);

  group('loadConfigurations', () {
    blocTest<ConfigurationsCubit, ConfigurationsState>(
      'should emit [loading, loaded] when configurations load successfully',
      build: () {
        final tEntity = EntityFactory.makeConfigurationsEntity();
        when(
          () => mockGetConfigurations.call(),
        ).thenAnswer((_) async => SuccessState(data: tEntity));
        return ConfigurationsCubit(useCases: useCases);
      },
      act: (cubit) => cubit.loadConfigurations(),
      expect: () => [
        isA<ConfigurationsState>().having(
          (s) => s.status,
          'status',
          DataStatus.loading,
        ),
        isA<ConfigurationsState>()
            .having((s) => s.status, 'status', DataStatus.loaded)
            .having(
              (s) => s.configurations,
              'configurations',
              isA<ConfigurationsEntity>(),
            ),
      ],
      verify: (_) {
        verify(() => mockGetConfigurations.call()).called(1);
      },
    );

    blocTest<ConfigurationsCubit, ConfigurationsState>(
      'should emit [loading, error] when configurations load fails',
      build: () {
        final tMessage = faker.lorem.sentence();
        when(
          () => mockGetConfigurations.call(),
        ).thenAnswer((_) async => FailureState(message: tMessage));
        return ConfigurationsCubit(useCases: useCases);
      },
      act: (cubit) => cubit.loadConfigurations(),
      expect: () => [
        isA<ConfigurationsState>().having(
          (s) => s.status,
          'status',
          DataStatus.loading,
        ),
        isA<ConfigurationsState>()
            .having((s) => s.status, 'status', DataStatus.loadingError)
            .having((s) => s.errorMessage, 'errorMessage', isNotEmpty),
      ],
      verify: (_) {
        verify(() => mockGetConfigurations.call()).called(1);
      },
    );
  });

  group('togglePushNotifications', () {
    blocTest<ConfigurationsCubit, ConfigurationsState>(
      'should emit [loaded] with updated preference immediately when toggle is called',
      build: () {
        when(
          () => mockSaveConfigurations.call(true),
        ).thenAnswer((_) async => const SuccessState(data: true));
        return ConfigurationsCubit(useCases: useCases);
      },
      act: (cubit) => cubit.togglePushNotifications(true),
      expect: () => [
        isA<ConfigurationsState>()
            .having((s) => s.status, 'status', DataStatus.loaded)
            .having(
              (s) => s.configurations.pushNotificationsEnabled,
              'pushNotificationsEnabled',
              true,
            ),
      ],
      verify: (_) {
        verify(() => mockSaveConfigurations.call(true)).called(1);
      },
    );
  });

  group('updateThemeMode', () {
    blocTest<ConfigurationsCubit, ConfigurationsState>(
      'should emit [loaded] with updated theme mode immediately when updateThemeMode is called',
      build: () {
        when(
          () => mockSaveThemeMode.call('dark'),
        ).thenAnswer((_) async => const SuccessState(data: true));
        return ConfigurationsCubit(useCases: useCases);
      },
      act: (cubit) => cubit.updateThemeMode(ThemeMode.dark),
      expect: () => [
        isA<ConfigurationsState>()
            .having((s) => s.status, 'status', DataStatus.loaded)
            .having((s) => s.configurations.themeMode, 'themeMode', 'dark'),
      ],
      verify: (_) {
        verify(() => mockSaveThemeMode.call('dark')).called(1);
      },
    );
  });

  group('clearAppCache', () {
    blocTest<ConfigurationsCubit, ConfigurationsState>(
      'should emit [loading, loaded] after clearing cache and redirect to LoginRoute',
      build: () {
        when(
          () => mockClearAppCache.call(),
        ).thenAnswer((_) async => SuccessState.nil);
        return ConfigurationsCubit(useCases: useCases);
      },
      act: (cubit) => cubit.clearAppCache(),
      expect: () => [
        isA<ConfigurationsState>().having(
          (s) => s.status,
          'status',
          DataStatus.loading,
        ),
        isA<ConfigurationsState>()
            .having((s) => s.status, 'status', DataStatus.loaded)
            .having(
              (s) => s.configurations.pushNotificationsEnabled,
              'pushNotificationsEnabled',
              true,
            )
            .having((s) => s.configurations.themeMode, 'themeMode', 'system'),
      ],
      verify: (_) {
        verify(() => mockClearAppCache.call()).called(1);
        verify(
          () => mockNavigationClient.replaceAllRoute(const LoginRoute()),
        ).called(1);
      },
    );
  });
}
