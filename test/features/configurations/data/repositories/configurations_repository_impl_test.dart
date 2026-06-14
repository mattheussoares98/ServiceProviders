import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/configurations/data/repositories/configurations_repository_impl.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockConfigurationsRemoteDataSource mockRemoteDataSource;
  late MockConfigurationsLocalDataSource mockLocalDataSource;
  late ConfigurationsRepositoryImpl repository;

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockConfigurationsRemoteDataSource();
    mockLocalDataSource = MockConfigurationsLocalDataSource();
    repository = ConfigurationsRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('getConfigurations', () {
    test('should return configurations from local data source', () async {
      final tEntity = EntityFactory.makeConfigurationsEntity();
      when(
        () => mockLocalDataSource.getConfigurations(),
      ).thenAnswer((_) async => SuccessState(data: tEntity));

      final result = await repository.getConfigurations();

      expect(result, SuccessState(data: tEntity));
      verify(() => mockLocalDataSource.getConfigurations()).called(1);
    });
  });

  group('savePushNotifications', () {
    test(
      'should save push notification preference in local data source',
      () async {
        final tEnabled = faker.randomGenerator.boolean();
        when(
          () => mockLocalDataSource.savePushNotifications(tEnabled),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.savePushNotifications(tEnabled);

        expect(result, const SuccessState(data: true));
        verify(
          () => mockLocalDataSource.savePushNotifications(tEnabled),
        ).called(1);
      },
    );
  });
}
