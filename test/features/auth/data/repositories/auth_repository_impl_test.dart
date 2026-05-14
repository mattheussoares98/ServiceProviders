import 'package:clean_architecture/core/data/models/responses/user_model.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user.dart';
import 'package:clean_architecture/core/domain/entities/user_data.dart';
import 'package:clean_architecture/features/auth/data/models/requests/authentication_model.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late MockAuthLocalDataSource mockAuthLocalDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockAuthRemoteDataSource,
      localDataSource: mockAuthLocalDataSource,
    );

    registerFallbackValue(
      const AuthenticationModel(username: '', password: ''),
    );
    registerFallbackValue(const UserDataEntity.empty());
    registerFallbackValue(
      const UserDataResponseModel(
        user: UserModel(
          id: 1,
          firstName: '',
          lastName: '',
          username: '',
          email: '',
          isActive: true,
        ),
        accessToken: '',
        refreshToken: '',
      ),
    );
  });

  // Test data
  const tAuthentication = AuthenticationEntity(
    username: 'test',
    password: 'password',
  );

  const tUser = User(
    id: 1,
    firstName: 'Test',
    lastName: 'User',
    username: 'test user',
    email: 'test@example.com',
    isActive: true,
  );
  const tUserData = UserDataEntity(
    user: tUser,
    accessToken: 'access',
    refreshToken: 'refresh',
  );

  // Build DTO from domain test data (not const because fromEntity is not const)
  final tUserDataModel = UserDataResponseModel.fromEntity(tUserData);

  group('login', () {
    test(
      'should call remoteDataSource.login when internet is connected and return its result mapped to domain',
      () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockAuthRemoteDataSource.login(any()),
        ).thenAnswer((_) async => SuccessState(data: tUserDataModel));

        // Act
        final result = await repository.login(tAuthentication);

        // Assert
        expect(result, isA<SuccessState<UserDataEntity>>());
        // repository maps DTO -> domain, so expect domain UserData
        expect(result.data, tUserData);
        verify(() => mockInternetClient.isConnected).called(1);
        verify(() => mockAuthRemoteDataSource.login(any())).called(1);
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
        final result = await repository.login(tAuthentication);

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
    test(
      'should call remoteDataSource.checkAUth when internet is connected and return its result',
      () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockAuthRemoteDataSource.checkAUth(),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.checkAuth();

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockInternetClient.isConnected).called(1);
        verify(() => mockAuthRemoteDataSource.checkAUth()).called(1);
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
        final result = await repository.checkAuth();

        // Assert
        expect(result, isA<FailureState<bool>>());
        expect(result.error, kNoInternet);
        verify(() => mockInternetClient.isConnected).called(1);
        verifyNoMoreInteractions(mockInternetClient);
        verifyZeroInteractions(mockAuthRemoteDataSource);
        verifyZeroInteractions(mockAuthLocalDataSource);
      },
    );
  });
}
