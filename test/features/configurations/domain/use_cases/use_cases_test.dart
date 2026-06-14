import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/configurations/domain/entities/configurations_entity.dart';
import 'package:clean_architecture/features/configurations/domain/use_cases/get_configurations_use_case.dart';
import 'package:clean_architecture/features/configurations/domain/use_cases/save_configurations_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockConfigurationsRepository mockRepository;
  late GetConfigurationsUseCase getUseCase;
  late SaveConfigurationsUseCase saveUseCase;

  setUp(() {
    mockRepository = MockConfigurationsRepository();
    getUseCase =
        GetConfigurationsUseCase(configurationsRepository: mockRepository);
    saveUseCase =
        SaveConfigurationsUseCase(configurationsRepository: mockRepository);
  });

  group('GetConfigurationsUseCase', () {
    test('should return SuccessState when call is successful', () async {
      final tEntity = EntityFactory.makeConfigurationsEntity();
      when(() => mockRepository.getConfigurations())
          .thenAnswer((_) async => SuccessState(data: tEntity));

      final result = await getUseCase();

      expect(result, SuccessState(data: tEntity));
      verify(() => mockRepository.getConfigurations()).called(1);
    });

    test('should return FailureState when call fails', () async {
      final tMessage = faker.lorem.sentence();
      when(() => mockRepository.getConfigurations())
          .thenAnswer((_) async => FailureState(message: tMessage));

      final result = await getUseCase();

      expect(result, FailureState<ConfigurationsEntity>(message: tMessage));
      verify(() => mockRepository.getConfigurations()).called(1);
    });
  });

  group('SaveConfigurationsUseCase', () {
    test('should return SuccessState when save is successful', () async {
      final tEnabled = faker.randomGenerator.boolean();
      when(() => mockRepository.savePushNotifications(tEnabled))
          .thenAnswer((_) async => const SuccessState(data: true));

      final result = await saveUseCase(tEnabled);

      expect(result, const SuccessState(data: true));
      verify(() => mockRepository.savePushNotifications(tEnabled)).called(1);
    });

    test('should return FailureState when save fails', () async {
      final tEnabled = faker.randomGenerator.boolean();
      final tMessage = faker.lorem.sentence();
      when(() => mockRepository.savePushNotifications(tEnabled))
          .thenAnswer((_) async => FailureState(message: tMessage));

      final result = await saveUseCase(tEnabled);

      expect(result, FailureState<bool>(message: tMessage));
      verify(() => mockRepository.savePushNotifications(tEnabled)).called(1);
    });
  });
}
