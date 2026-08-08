import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/requests/authentication_request_model.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/requests/sign_up_request_model.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:o_jogo_da_obra/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_response_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late MockAuthLocalDataSource mockAuthLocalDataSource;
  late MockUsersLocalDataSource mockUsersLocalDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    mockUsersLocalDataSource = MockUsersLocalDataSource();
    repository = AuthRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockAuthRemoteDataSource,
      localDataSource: mockAuthLocalDataSource,
      usersLocalDataSource: mockUsersLocalDataSource,
    );

    registerFallbackValue(
      const AuthenticationRequestModel(email: '', password: ''),
    );
    registerFallbackValue(UserDataEntity.empty());
    registerFallbackValue(
      UserDataResponseModel(
        user: UserProfileResponseModel.fromEntity(
          EntityFactory.makeUserProfileEntity(),
        ),
        accessToken: '',
        refreshToken: '',
      ),
    );
    registerFallbackValue(
      const SignUpRequestModel(name: '', email: '', password: ''),
    );
    registerFallbackValue(
      UserProfileResponseModel.fromEntity(
        EntityFactory.makeUserProfileEntity(),
      ),
    );
  });

  // Test data
  final tAuthentication = EntityFactory.makeAuthentication().copyWith(
    username: 'test',
    password: 'password',
  );

  final tUser = EntityFactory.makeUserProfileEntity().copyWith(
    id: '1',
    name: 'test user',
    email: 'test@example.com',
    isActive: true,
  );
  final tUserData = EntityFactory.makeUserDataEntity().copyWith(
    user: tUser,
    accessToken: 'access',
    refreshToken: 'refresh',
  );

  // Build DTO from domain test data
  final tUserDataModel = UserDataResponseModel.fromEntity(tUserData);
  final tUserProfileModel = UserProfileResponseModel.fromEntity(tUser);
  final tIncompleteUserDataModel = UserDataResponseModel.fromEntity(
    tUserData.copyWith(user: tUser.copyWith(id: '')),
  );
  final tProviderUserDataModel = UserDataResponseModel.fromEntity(
    tUserData.copyWith(user: tUser.copyWith(companyId: '')),
  );
  final tUserDataModelWithProfile = UserDataResponseModel(
    user: tUserProfileModel,
    accessToken: tUserData.accessToken,
    refreshToken: tUserData.refreshToken,
  );

  group('login', () {
    test(
      'should call remoteDataSource.login when internet is connected and return its result mapped to domain',
      () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(() => mockAuthRemoteDataSource.login(any())).thenAnswer(
          (_) async => SuccessState(data: tUserDataModelWithProfile),
        );
        when(
          () => mockUsersLocalDataSource.saveUserProfile(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.login(tAuthentication);

        // Assert
        expect(result, isA<SuccessState<UserDataEntity>>());
        expect(result.data, tUserData);
        verify(() => mockInternetClient.isConnected).called(1);
        verify(() => mockAuthRemoteDataSource.login(any())).called(1);
        verifyNever(
          () => mockAuthRemoteDataSource.getCurrentUserProfile(any()),
        );
        verify(
          () => mockUsersLocalDataSource.saveUserProfile(tUserProfileModel),
        ).called(1);
        verifyNoMoreInteractions(mockInternetClient);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
        verifyZeroInteractions(mockAuthLocalDataSource);
        verifyNoMoreInteractions(mockUsersLocalDataSource);
      },
    );

    test(
      'should save profile from login response without fetching it again',
      () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(() => mockAuthRemoteDataSource.login(any())).thenAnswer(
          (_) async => SuccessState(data: tUserDataModelWithProfile),
        );
        when(
          () => mockUsersLocalDataSource.saveUserProfile(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.login(tAuthentication);

        // Assert
        expect(result, isA<SuccessState<UserDataEntity>>());
        verify(() => mockAuthRemoteDataSource.login(any())).called(1);
        verifyNever(
          () => mockAuthRemoteDataSource.getCurrentUserProfile(any()),
        );
        verify(
          () => mockUsersLocalDataSource.saveUserProfile(tUserProfileModel),
        ).called(1);
      },
    );

    test('should return FailureState when remote login fails', () async {
      // Arrange
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockAuthRemoteDataSource.login(any()),
      ).thenAnswer((_) async => FailureState<UserDataResponseModel>());

      // Act
      final result = await repository.login(tAuthentication);

      // Assert
      expect(result, isA<FailureState<UserDataEntity>>());
      verify(() => mockAuthRemoteDataSource.login(any())).called(1);
      verifyNever(() => mockAuthRemoteDataSource.getCurrentUserProfile(any()));
      verifyZeroInteractions(mockUsersLocalDataSource);
    });

    test(
      'should return FailureState when login response has empty user id',
      () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockAuthRemoteDataSource.login(any()),
        ).thenAnswer((_) async => SuccessState(data: tIncompleteUserDataModel));

        // Act
        final result = await repository.login(tAuthentication);

        // Assert
        expect(result, isA<FailureState<UserDataEntity>>());
        verify(() => mockAuthRemoteDataSource.login(any())).called(1);
        verifyNever(
          () => mockAuthRemoteDataSource.getCurrentUserProfile(any()),
        );
        verifyZeroInteractions(mockUsersLocalDataSource);
      },
    );

    test(
      'should return SuccessState when login response has empty companyId (Service Provider)',
      () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockAuthRemoteDataSource.login(any()),
        ).thenAnswer((_) async => SuccessState(data: tProviderUserDataModel));

        // Act
        final result = await repository.login(tAuthentication);

        // Assert
        expect(result, isA<SuccessState<UserDataEntity>>());
        verify(() => mockAuthRemoteDataSource.login(any())).called(1);
        verifyZeroInteractions(mockUsersLocalDataSource);
      },
    );

    test(
      'should return FailureState when saving user profile locally fails',
      () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(() => mockAuthRemoteDataSource.login(any())).thenAnswer(
          (_) async => SuccessState(data: tUserDataModelWithProfile),
        );
        when(
          () => mockUsersLocalDataSource.saveUserProfile(any()),
        ).thenAnswer((_) async => FailureState<bool>());

        // Act
        final result = await repository.login(tAuthentication);

        // Assert
        expect(result, isA<FailureState<UserDataEntity>>());
        verify(
          () => mockUsersLocalDataSource.saveUserProfile(tUserProfileModel),
        ).called(1);
      },
    );

    test(
      'should return FailureState.noInternet when internet is not connected',
      () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(false);

        // Act
        final result = await repository.login(tAuthentication);

        // Assert
        expect(result, isA<FailureState<UserDataEntity>>());
        expect(result.error, kNoInternet);
        verify(() => mockInternetClient.isConnected).called(1);
        verifyNoMoreInteractions(mockInternetClient);
        verifyZeroInteractions(mockAuthRemoteDataSource);
        verifyZeroInteractions(mockAuthLocalDataSource);
        verifyZeroInteractions(mockUsersLocalDataSource);
      },
    );
  });

  group('signUp', () {
    final tSignUpEntity = EntityFactory.makeSignUp().copyWith(
      name: 'Test',
      email: 'test@example.com',
      password: 'password',
    );

    test(
      'should call remoteDataSource.signUp when internet is connected and return its result mapped to domain',
      () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockAuthRemoteDataSource.signUp(any()),
        ).thenAnswer((_) async => SuccessState(data: tUserDataModel));

        // Act
        final result = await repository.signUp(tSignUpEntity);

        // Assert
        expect(result, isA<SuccessState<UserDataEntity>>());
        expect(result.data, tUserData);
        verify(() => mockInternetClient.isConnected).called(1);
        verify(() => mockAuthRemoteDataSource.signUp(any())).called(1);
        verifyNoMoreInteractions(mockInternetClient);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
        verifyZeroInteractions(mockAuthLocalDataSource);
      },
    );

    test(
      'should return FailureState.noInternet when internet is not connected',
      () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(false);

        // Act
        final result = await repository.signUp(tSignUpEntity);

        // Assert
        expect(result, isA<FailureState<UserDataEntity>>());
        expect(result.error, kNoInternet);
        verify(() => mockInternetClient.isConnected).called(1);
        verifyNoMoreInteractions(mockInternetClient);
        verifyZeroInteractions(mockAuthRemoteDataSource);
        verifyZeroInteractions(mockAuthLocalDataSource);
      },
    );
  });

  group('resetPassword', () {
    test('should call remoteDataSource.resetPassword', () async {
      // Arrange
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockAuthRemoteDataSource.resetPassword(any()),
      ).thenAnswer((_) async => SuccessState.nil);

      // Act
      final result = await repository.resetPassword('test@example.com');

      // Assert
      expect(result, isA<SuccessState<void>>());
      verify(
        () => mockAuthRemoteDataSource.resetPassword('test@example.com'),
      ).called(1);
    });
  });

  group('changePassword', () {
    test('should call remoteDataSource.changePassword', () async {
      final tPassword = faker.internet.password();
      // Arrange
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockAuthRemoteDataSource.changePassword(any()),
      ).thenAnswer((_) async => SuccessState.nil);

      // Act
      final result = await repository.changePassword(tPassword);

      // Assert
      expect(result, isA<SuccessState<void>>());
      verify(
        () => mockAuthRemoteDataSource.changePassword(tPassword),
      ).called(1);
    });
  });

  group('saveUserData', () {
    test(
      'should call localDataSource.saveUserData and return its result',
      () async {
        // Arrange
        when(
          () => mockAuthLocalDataSource.saveUserData(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.saveUserData(tUserData);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        // repository currently passes a DTO built from domain to the local data source.
        // Use a flexible argument matcher to avoid fragile instance-equality.
        verify(() => mockAuthLocalDataSource.saveUserData(any())).called(1);
        verifyNoMoreInteractions(mockAuthLocalDataSource);
        verifyZeroInteractions(mockInternetClient);
        verifyZeroInteractions(mockAuthRemoteDataSource);
      },
    );
  });

  group('getUserData', () {
    test(
      'should call localDataSource.getUserData and return its result mapped to domain',
      () async {
        // Arrange
        when(
          () => mockAuthLocalDataSource.getUserData(),
        ).thenAnswer((_) async => SuccessState(data: tUserDataModel));

        // Act
        final result = await repository.getUserData();

        // Assert
        expect(result, isA<SuccessState<UserDataEntity>>());
        // local DTO should be mapped to domain UserData
        expect(result.data, tUserData);
        verify(() => mockAuthLocalDataSource.getUserData()).called(1);
        verifyNoMoreInteractions(mockAuthLocalDataSource);
        verifyZeroInteractions(mockInternetClient);
        verifyZeroInteractions(mockAuthRemoteDataSource);
      },
    );
  });

  group('checkAuth', () {
    test('should call remoteDataSource.checkAuth and return its result', () {
      // Arrange
      when(() => mockAuthRemoteDataSource.checkAuth()).thenReturn(true);

      // Act
      final result = repository.checkAuth();

      // Assert
      expect(result, isTrue);
      verify(() => mockAuthRemoteDataSource.checkAuth()).called(1);
    });
  });

  group('currentAuthUser', () {
    test('should return remoteDataSource.currentAuthUser', () {
      final tAuthUser = EntityFactory.makeAuthUserEntity();
      when(() => mockAuthRemoteDataSource.currentAuthUser).thenReturn(tAuthUser);

      final result = repository.currentAuthUser;
      expect(result, equals(tAuthUser));
      verify(() => mockAuthRemoteDataSource.currentAuthUser).called(1);
    });
  });

  group('authUserIdStream', () {
    test('should return remoteDataSource.authUserIdStream', () {
      final stream = Stream<String?>.value(faker.guid.guid());
      when(() => mockAuthRemoteDataSource.authUserIdStream).thenAnswer((_) => stream);

      final result = repository.authUserIdStream;
      expect(result, equals(stream));
      verify(() => mockAuthRemoteDataSource.authUserIdStream).called(1);
    });
  });

  group('logout', () {
    test('should call remoteDataSource.logout', () async {
      when(() => mockAuthRemoteDataSource.logout()).thenAnswer((_) async {});

      await repository.logout();
      verify(() => mockAuthRemoteDataSource.logout()).called(1);
    });
  });
}
