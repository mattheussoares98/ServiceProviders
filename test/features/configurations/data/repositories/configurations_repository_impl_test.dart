import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/configurations/data/models/responses/configurations_response_model.dart';
import 'package:o_jogo_da_obra/features/configurations/data/repositories/configurations_repository_impl.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/entities/configurations_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockConfigurationsRemoteDataSource mockRemoteDataSource;
  late MockConfigurationsLocalDataSource mockLocalDataSource;
  late MockSessionRepository mockSessionRepository;
  late ConfigurationsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeConfigurationsEntity());
    registerFallbackValue(
      ConfigurationsResponseModel.fromEntity(
        EntityFactory.makeConfigurationsEntity(),
      ),
    );
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockConfigurationsRemoteDataSource();
    mockLocalDataSource = MockConfigurationsLocalDataSource();
    mockSessionRepository = MockSessionRepository();
    repository = ConfigurationsRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      sessionRepository: mockSessionRepository,
    );
  });

  group('getConfigurations', () {
    test(
      'should return remote configurations and save them locally when online',
      () async {
        final tUserId = faker.guid.guid();
        final tEntity = EntityFactory.makeConfigurationsEntity();
        final tModel = ConfigurationsResponseModel.fromEntity(tEntity);
        final tUser = EntityFactory.makeUserProfileEntity().copyWith(
          id: tUserId,
        );
        final tSession = UserDataEntity(
          user: tUser,
          accessToken: faker.jwt.valid(),
          refreshToken: faker.jwt.valid(),
        );

        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(() => mockSessionRepository.userData).thenReturn(tSession);
        when(
          () => mockRemoteDataSource.getConfigurations(tUserId),
        ).thenAnswer((_) async => SuccessState(data: tModel));
        when(
          () => mockLocalDataSource.saveConfigurations(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getConfigurations();

        expect(result, SuccessState(data: tEntity));
        verify(() => mockRemoteDataSource.getConfigurations(tUserId)).called(1);
        verify(() => mockLocalDataSource.saveConfigurations(tModel)).called(1);
      },
    );

    test('should return failure when remote fetch fails and online', () async {
      final tUserId = faker.guid.guid();
      final tUser = EntityFactory.makeUserProfileEntity().copyWith(id: tUserId);
      final tSession = UserDataEntity(
        user: tUser,
        accessToken: faker.jwt.valid(),
        refreshToken: faker.jwt.valid(),
      );

      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(() => mockSessionRepository.userData).thenReturn(tSession);
      when(
        () => mockRemoteDataSource.getConfigurations(tUserId),
      ).thenAnswer((_) async => FailureState(message: 'Error'));

      final result = await repository.getConfigurations();

      expect(result, isA<FailureState<ConfigurationsEntity>>());
      verify(() => mockRemoteDataSource.getConfigurations(tUserId)).called(1);
      verifyNever(() => mockLocalDataSource.saveConfigurations(any()));
    });

    test('should fallback to local configurations when offline', () async {
      final tEntity = EntityFactory.makeConfigurationsEntity();
      final tModel = ConfigurationsResponseModel.fromEntity(tEntity);

      when(() => mockInternetClient.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getConfigurations(),
      ).thenAnswer((_) async => SuccessState(data: tModel));

      final result = await repository.getConfigurations();

      expect(result, SuccessState(data: tEntity));
      verify(() => mockLocalDataSource.getConfigurations()).called(1);
      verifyNever(() => mockRemoteDataSource.getConfigurations(any()));
    });
  });

  group('savePushNotifications', () {
    test(
      'should save configurations remotely and locally when online',
      () async {
        final tUserId = faker.guid.guid();
        final tEnabled = faker.randomGenerator.boolean();
        final tEntity = EntityFactory.makeConfigurationsEntity();
        final tModel = ConfigurationsResponseModel.fromEntity(tEntity);
        final tUser = EntityFactory.makeUserProfileEntity().copyWith(
          id: tUserId,
        );
        final tSession = UserDataEntity(
          user: tUser,
          accessToken: faker.jwt.valid(),
          refreshToken: faker.jwt.valid(),
        );

        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(() => mockSessionRepository.userData).thenReturn(tSession);
        when(
          () => mockLocalDataSource.getConfigurations(),
        ).thenAnswer((_) async => SuccessState(data: tModel));
        when(
          () => mockRemoteDataSource.saveConfigurations(
            userId: tUserId,
            pushNotificationsEnabled: tEnabled,
            themeMode: tEntity.themeMode,
          ),
        ).thenAnswer((_) async => SuccessState.nil);
        when(
          () => mockLocalDataSource.savePushNotifications(tEnabled),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.savePushNotifications(tEnabled);

        expect(result, const SuccessState(data: true));
        verify(
          () => mockRemoteDataSource.saveConfigurations(
            userId: tUserId,
            pushNotificationsEnabled: tEnabled,
            themeMode: tEntity.themeMode,
          ),
        ).called(1);
        verify(
          () => mockLocalDataSource.savePushNotifications(tEnabled),
        ).called(1);
      },
    );

    test('should return failure when remote save fails and online', () async {
      final tUserId = faker.guid.guid();
      final tEnabled = faker.randomGenerator.boolean();
      final tEntity = EntityFactory.makeConfigurationsEntity();
      final tModel = ConfigurationsResponseModel.fromEntity(tEntity);
      final tUser = EntityFactory.makeUserProfileEntity().copyWith(id: tUserId);
      final tSession = UserDataEntity(
        user: tUser,
        accessToken: faker.jwt.valid(),
        refreshToken: faker.jwt.valid(),
      );

      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(() => mockSessionRepository.userData).thenReturn(tSession);
      when(
        () => mockLocalDataSource.getConfigurations(),
      ).thenAnswer((_) async => SuccessState(data: tModel));
      when(
        () => mockRemoteDataSource.saveConfigurations(
          userId: tUserId,
          pushNotificationsEnabled: tEnabled,
          themeMode: tEntity.themeMode,
        ),
      ).thenAnswer((_) async => FailureState(message: 'Remote Error'));

      final result = await repository.savePushNotifications(tEnabled);

      expect(result, isA<FailureState<bool>>());
      verifyNever(() => mockLocalDataSource.savePushNotifications(any()));
    });

    test('should save configurations locally only when offline', () async {
      final tEnabled = faker.randomGenerator.boolean();

      when(() => mockInternetClient.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.savePushNotifications(tEnabled),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.savePushNotifications(tEnabled);

      expect(result, const SuccessState(data: true));
      verify(
        () => mockLocalDataSource.savePushNotifications(tEnabled),
      ).called(1);
      verifyNever(
        () => mockRemoteDataSource.saveConfigurations(
          userId: any(named: 'userId'),
          pushNotificationsEnabled: any(named: 'pushNotificationsEnabled'),
          themeMode: any(named: 'themeMode'),
        ),
      );
    });
  });
}
