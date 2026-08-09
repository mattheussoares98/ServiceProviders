import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/entities/configurations_entity.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/clear_app_cache_use_case.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/get_configurations_use_case.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/save_configurations_use_case.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/save_theme_mode_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockConfigurationsRepository mockRepository;
  late GetConfigurationsUseCase getUseCase;
  late SaveConfigurationsUseCase saveUseCase;
  late SaveThemeModeUseCase saveThemeModeUseCase;
  late ClearAppCacheUseCase clearAppCacheUseCase;

  setUp(() {
    mockRepository = MockConfigurationsRepository();
    getUseCase = GetConfigurationsUseCase(
      configurationsRepository: mockRepository,
    );
    saveUseCase = SaveConfigurationsUseCase(
      configurationsRepository: mockRepository,
    );
    saveThemeModeUseCase = SaveThemeModeUseCase(
      configurationsRepository: mockRepository,
    );
    clearAppCacheUseCase = ClearAppCacheUseCase(
      configurationsRepository: mockRepository,
    );
  });

  group('GetConfigurationsUseCase', () {
    test('should return SuccessState when call is successful', () async {
      final tEntity = EntityFactory.makeConfigurationsEntity();
      when(
        () => mockRepository.getConfigurations(),
      ).thenAnswer((_) async => SuccessState(data: tEntity));

      final result = await getUseCase();

      expect(result, SuccessState(data: tEntity));
      verify(() => mockRepository.getConfigurations()).called(1);
    });

    test('should return FailureState when call fails', () async {
      final tMessage = faker.lorem.sentence();
      when(
        () => mockRepository.getConfigurations(),
      ).thenAnswer((_) async => FailureState(message: tMessage));

      final result = await getUseCase();

      expect(result, FailureState<ConfigurationsEntity>(message: tMessage));
      verify(() => mockRepository.getConfigurations()).called(1);
    });
  });

  group('SaveConfigurationsUseCase', () {
    test('should return SuccessState when save is successful', () async {
      final tEnabled = faker.randomGenerator.boolean();
      when(
        () => mockRepository.savePushNotifications(tEnabled),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await saveUseCase(tEnabled);

      expect(result, const SuccessState(data: true));
      verify(() => mockRepository.savePushNotifications(tEnabled)).called(1);
    });

    test('should return FailureState when save fails', () async {
      final tEnabled = faker.randomGenerator.boolean();
      final tMessage = faker.lorem.sentence();
      when(
        () => mockRepository.savePushNotifications(tEnabled),
      ).thenAnswer((_) async => FailureState(message: tMessage));

      final result = await saveUseCase(tEnabled);

      expect(result, FailureState<bool>(message: tMessage));
      verify(() => mockRepository.savePushNotifications(tEnabled)).called(1);
    });
  });

  group('SaveThemeModeUseCase', () {
    test('should return SuccessState when theme mode save is successful', () async {
      final tMode = faker.lorem.word();
      when(
        () => mockRepository.saveThemeMode(tMode),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await saveThemeModeUseCase(tMode);

      expect(result, const SuccessState(data: true));
      verify(() => mockRepository.saveThemeMode(tMode)).called(1);
    });

    test('should return FailureState when theme mode save fails', () async {
      final tMode = faker.lorem.word();
      final tMessage = faker.lorem.sentence();
      when(
        () => mockRepository.saveThemeMode(tMode),
      ).thenAnswer((_) async => FailureState(message: tMessage));

      final result = await saveThemeModeUseCase(tMode);

      expect(result, FailureState<bool>(message: tMessage));
      verify(() => mockRepository.saveThemeMode(tMode)).called(1);
    });
  });

  group('ClearAppCacheUseCase', () {
    test('should return SuccessState when clearing app cache is successful', () async {
      when(
        () => mockRepository.clearAppCache(),
      ).thenAnswer((_) async => const SuccessState(data: null));

      final result = await clearAppCacheUseCase();

      expect(result, const SuccessState(data: null));
      verify(() => mockRepository.clearAppCache()).called(1);
    });

    test('should return FailureState when clearing app cache fails', () async {
      final tMessage = faker.lorem.sentence();
      when(
        () => mockRepository.clearAppCache(),
      ).thenAnswer((_) async => FailureState(message: tMessage));

      final result = await clearAppCacheUseCase();

      expect(result, FailureState<void>(message: tMessage));
      verify(() => mockRepository.clearAppCache()).called(1);
    });
  });
}
