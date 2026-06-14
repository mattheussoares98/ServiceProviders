import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/configurations/domain/entities/configurations_entity.dart';
import 'package:clean_architecture/features/configurations/presentation/cubits/configurations/configurations_cubit.dart';
import 'package:clean_architecture/features/configurations/presentation/cubits/configurations/configurations_cubit_use_cases.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/external/router_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  late MockGetConfigurationsUseCase mockGetConfigurations;
  late MockSaveConfigurationsUseCase mockSaveConfigurations;
  late MockLocalStorageClient mockLocalStorageClient;
  late MockNavigationClient mockNavigationClient;
  late ConfigurationsCubit cubit;

  setUpAll(() {
    registerFallbackValue(const MockPageRouteInfo());
    registerFallbackValue(EntityFactory.makeConfigurationsEntity());
  });

  setUp(() {
    mockGetConfigurations = MockGetConfigurationsUseCase();
    mockSaveConfigurations = MockSaveConfigurationsUseCase();
    mockLocalStorageClient = MockLocalStorageClient();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    when(() => mockLocalStorageClient.getThemeMode()).thenReturn('system');

    final useCases = ConfigurationsCubitUseCases(
      getConfigurations: mockGetConfigurations,
      saveConfigurations: mockSaveConfigurations,
    );

    cubit = ConfigurationsCubit(
      useCases: useCases,
      localStorageClient: mockLocalStorageClient,
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
        return cubit;
      },
      act: (cubit) => cubit.loadConfigurations(),
      expect: () => [
        isA<ConfigurationsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<ConfigurationsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
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
        return cubit;
      },
      act: (cubit) => cubit.loadConfigurations(),
      expect: () => [
        isA<ConfigurationsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<ConfigurationsState>()
            .having((s) => s.status, 'status', StateStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotEmpty),
      ],
      verify: (_) {
        verify(() => mockGetConfigurations.call()).called(1);
      },
    );
  });

  group('togglePushNotifications', () {
    blocTest<ConfigurationsCubit, ConfigurationsState>(
      'should emit [loading, loaded] with updated preference when toggle succeeds',
      build: () {
        when(
          () => mockSaveConfigurations.call(true),
        ).thenAnswer((_) async => const SuccessState(data: true));
        return cubit;
      },
      act: (cubit) => cubit.togglePushNotifications(true),
      expect: () => [
        isA<ConfigurationsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<ConfigurationsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
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

    blocTest<ConfigurationsCubit, ConfigurationsState>(
      'should emit [loading, error] when toggle fails',
      build: () {
        when(
          () => mockSaveConfigurations.call(any()),
        ).thenAnswer((_) async => FailureState(message: 'Failed to save'));
        return cubit;
      },
      act: (cubit) => cubit.togglePushNotifications(false),
      expect: () => [
        isA<ConfigurationsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<ConfigurationsState>().having(
          (s) => s.status,
          'status',
          StateStatus.error,
        ),
      ],
      verify: (_) {
        verify(() => mockSaveConfigurations.call(false)).called(1);
      },
    );
  });

  group('updateThemeMode', () {
    blocTest<ConfigurationsCubit, ConfigurationsState>(
      'should emit [loading, loaded] with updated theme mode when updateThemeMode succeeds',
      build: () {
        when(
          () => mockLocalStorageClient.saveThemeMode(any()),
        ).thenAnswer((_) async => {});
        return cubit;
      },
      act: (cubit) => cubit.updateThemeMode(ThemeMode.dark),
      expect: () => [
        isA<ConfigurationsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<ConfigurationsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.configurations.themeMode, 'themeMode', 'dark'),
      ],
      verify: (_) {
        verify(() => mockLocalStorageClient.saveThemeMode('dark')).called(1);
      },
    );
  });

  group('clearAppCache', () {
    blocTest<ConfigurationsCubit, ConfigurationsState>(
      'should emit [loading, loaded] after clearing cache and redirect to LoginRoute',
      build: () {
        when(
          () => mockLocalStorageClient.clearAll(),
        ).thenAnswer((_) async => {});
        return cubit;
      },
      act: (cubit) => cubit.clearAppCache(),
      expect: () => [
        isA<ConfigurationsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<ConfigurationsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having(
              (s) => s.configurations.pushNotificationsEnabled,
              'pushNotificationsEnabled',
              true,
            )
            .having((s) => s.configurations.themeMode, 'themeMode', 'system'),
      ],
      verify: (_) {
        verify(() => mockLocalStorageClient.clearAll()).called(1);
        verify(
          () => mockNavigationClient.replaceAllRoute(const LoginRoute()),
        ).called(1);
      },
    );
  });
}
