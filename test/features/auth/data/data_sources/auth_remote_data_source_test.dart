import 'package:clean_architecture/config/app_config.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:clean_architecture/routing/helper/route_data.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/external/external_mocks.dart';

void main() {
  late MockSupabaseAuthClient mockSupabaseAuthClient;
  late AuthRemoteDataSourceImpl dataSource;
  late AuthResponse fakeAuthResponse;

  setUp(() {
    GetIt.I.registerLazySingleton<AppConfig>(() => const TestAppConfig());

    mockSupabaseAuthClient = MockSupabaseAuthClient();
    dataSource = AuthRemoteDataSourceImpl(supabaseAuth: mockSupabaseAuthClient);
    fakeAuthResponse = AuthResponse(user: EntityFactory.makeUser());
  });

  tearDown(() => GetIt.I.reset());

  group('login', () {
    final tAuthenticationRequest = EntityFactory.makeAuthenticationModel();

    test(
      'should return SuccessState with UserDataResponseModel when Supabase login is successful',
      () async {
        // Arrange
        when(
          () => mockSupabaseAuthClient.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => fakeAuthResponse);

        // Act
        final result = await dataSource.login(tAuthenticationRequest);

        // Assert
        expect(result, isA<SuccessState<UserDataResponseModel>>());
        expect(
          result.data,
          UserDataResponseModel.fromSupabase(fakeAuthResponse),
        );

        verify(
          () => mockSupabaseAuthClient.signInWithPassword(
            email: tAuthenticationRequest.email,
            password: tAuthenticationRequest.password,
          ),
        ).called(1);
      },
    );

    test(
      'should return FailureState when Supabase throws AuthException',
      () async {
        // Arrange
        const exception = AuthException(
          'Invalid credentials',
          code: 'invalid_credentials',
        );

        when(
          () => mockSupabaseAuthClient.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(exception);

        // Act
        final result = await dataSource.login(tAuthenticationRequest);

        // Assert
        expect(result, isA<FailureState<UserDataResponseModel>>());
        final failure = result as FailureState<UserDataResponseModel>;
        expect(failure.message, isNotEmpty);
      },
    );
  });

  group('signUp', () {
    final tSignUpRequest = EntityFactory.makeSignUpRequest();

    test(
      'should return SuccessState with UserDataResponseModel when Supabase signUp is successful',
      () async {
        // The expected redirect URL is base URL + email-confirmation path
        const expectedRedirectUrl =
            '${TestAppConfig.defaultWebBaseUrl}$kEmailConfirmationPath';

        // Arrange
        when(
          () => mockSupabaseAuthClient.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            emailRedirectTo: any(named: 'emailRedirectTo'),
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => fakeAuthResponse);

        // Act
        final result = await dataSource.signUp(tSignUpRequest);

        // Assert
        expect(result, isA<SuccessState<UserDataResponseModel>>());
        expect(
          result.data,
          UserDataResponseModel.fromSupabase(fakeAuthResponse),
        );

        verify(
          () => mockSupabaseAuthClient.signUp(
            email: tSignUpRequest.email,
            password: tSignUpRequest.password,
            emailRedirectTo: expectedRedirectUrl,
            data: {'name': tSignUpRequest.name},
          ),
        ).called(1);
      },
    );

    test(
      'should return FailureState when Supabase throws AuthException during signUp',
      () async {
        // Arrange
        const exception = AuthException(
          'Email already exists',
          code: 'email_exists',
        );

        when(
          () => mockSupabaseAuthClient.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            emailRedirectTo: any(named: 'emailRedirectTo'),
            data: any(named: 'data'),
          ),
        ).thenThrow(exception);

        // Act
        final result = await dataSource.signUp(tSignUpRequest);

        // Assert
        expect(result, isA<FailureState<UserDataResponseModel>>());
        final failure = result as FailureState<UserDataResponseModel>;
        expect(failure.message, isNotEmpty);
      },
    );
  });

  group('resetPassword', () {
    final email = faker.internet.email();
    test('should return SuccessState when reset email is sent', () async {
      // Arrange
      when(
        () => mockSupabaseAuthClient.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await dataSource.resetPassword(email);

      // Assert
      expect(result, isA<SuccessState<void>>());
      verify(
        () => mockSupabaseAuthClient.resetPasswordForEmail(
          email,
          redirectTo: '${TestAppConfig.defaultWebBaseUrl}$kChangePasswordPath',
        ),
      ).called(1);
    });

    test('should return FailureState when reset fails', () async {
      // Arrange
      when(
        () => mockSupabaseAuthClient.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenThrow(const AuthException('Error sending email'));

      // Act
      final result = await dataSource.resetPassword(email);

      // Assert
      expect(result, isA<FailureState<void>>());
    });
  });

  group('changePassword', () {
    final newPassword = faker.internet.password();
    test('should return SuccessState when password is changed successfully', () async {
      // Arrange
      when(
        () => mockSupabaseAuthClient.updateUserPassword(any()),
      ).thenAnswer((_) async {});

      // Act
      final result = await dataSource.changePassword(newPassword);

      // Assert
      expect(result, isA<SuccessState<void>>());
      verify(
        () => mockSupabaseAuthClient.updateUserPassword(newPassword),
      ).called(1);
    });

    test('should return FailureState when password update fails', () async {
      // Arrange
      when(
        () => mockSupabaseAuthClient.updateUserPassword(any()),
      ).thenThrow(const AuthException('Error updating password'));

      // Act
      final result = await dataSource.changePassword(newPassword);

      // Assert
      expect(result, isA<FailureState<void>>());
    });
  });

  group('checkAuth', () {
    test('should return true when session is not null', () {
      // Arrange
      when(() => mockSupabaseAuthClient.currentSession).thenReturn(
        Session(
          accessToken: faker.randomGenerator.string(10),
          tokenType: faker.randomGenerator.string(10),
          user: User(
            id: faker.guid.guid(),
            appMetadata: {},
            userMetadata: {},
            aud: faker.randomGenerator.string(10),
            createdAt: faker.date.dateTime().toIso8601String(),
          ),
        ),
      );

      // Act
      final result = dataSource.checkAuth();

      // Assert
      expect(result, isTrue);
    });

    test('should return false when session is null', () {
      // Arrange
      when(() => mockSupabaseAuthClient.currentSession).thenReturn(null);

      // Act
      final result = dataSource.checkAuth();

      // Assert
      expect(result, isFalse);
    });
  });
}
