import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/constants/local_db_keys.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/theme/theme_cubit.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../testing/mocks/client_mocks.dart';

void main() {
  late MockLocalStorageClient mockLocalStorageClient;
  late MockNavigationClient mockNavigationClient;
  late ThemeCubit themeCubit;

  setUp(() {
    mockLocalStorageClient = MockLocalStorageClient();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);
  });

  tearDown(GetIt.I.reset);

  group('ThemeCubit', () {
    test('should initialize with ThemeMode.system when no theme is cached', () {
      // Arrange
      when(() => mockLocalStorageClient.getString(LocalDbKeys.themeMode))
          .thenReturn(null);

      // Act
      themeCubit = ThemeCubit(mockLocalStorageClient);

      // Assert
      expect(themeCubit.state.themeMode, equals(ThemeMode.system));
      expect(themeCubit.state.status, equals(StateStatus.loaded));
      verify(() => mockLocalStorageClient.getString(LocalDbKeys.themeMode))
          .called(1);
    });

    test('should initialize with cached theme mode when present', () {
      // Arrange
      final cachedMode = faker.randomGenerator.element([
        ThemeMode.light.name,
        ThemeMode.dark.name,
        ThemeMode.system.name,
      ]);
      when(() => mockLocalStorageClient.getString(LocalDbKeys.themeMode))
          .thenReturn(cachedMode);

      // Act
      themeCubit = ThemeCubit(mockLocalStorageClient);

      // Assert
      final expectedMode =
          ThemeMode.values.firstWhere((e) => e.name == cachedMode);
      expect(themeCubit.state.themeMode, equals(expectedMode));
      expect(themeCubit.state.status, equals(StateStatus.loaded));
      verify(() => mockLocalStorageClient.getString(LocalDbKeys.themeMode))
          .called(1);
    });

    blocTest<ThemeCubit, ThemeState>(
      'should emit [loading, loaded] with updated ThemeMode and save it to storage when updateThemeMode is called',
      build: () {
        when(() => mockLocalStorageClient.getString(LocalDbKeys.themeMode))
            .thenReturn(null);
        when(() => mockLocalStorageClient.setString(any(), any()))
            .thenAnswer((_) async => true);
        return ThemeCubit(mockLocalStorageClient);
      },
      act: (cubit) => cubit.updateThemeMode(ThemeMode.dark),
      expect: () => [
        const ThemeState(
          themeMode: ThemeMode.dark,
          status: StateStatus.loading,
        ),
        const ThemeState(
          themeMode: ThemeMode.dark,
          status: StateStatus.loaded,
        ),
      ],
      verify: (_) {
        verify(
          () => mockLocalStorageClient.setString(
            LocalDbKeys.themeMode,
            ThemeMode.dark.name,
          ),
        ).called(1);
      },
    );
  });
}
