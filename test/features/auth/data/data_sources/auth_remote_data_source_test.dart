import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:clean_architecture/features/auth/data/models/requests/authentication_model.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/mocks/external/external_mocks.dart';

void main() {
  late MockSupabaseAuthClient mockSupabaseAuthClient;
  late AuthRemoteDataSourceImpl dataSource;
  late AuthResponse fakeAuthResponse;

  setUp(() {
    mockSupabaseAuthClient = MockSupabaseAuthClient();
    dataSource = AuthRemoteDataSourceImpl(supabaseAuth: mockSupabaseAuthClient);
    fakeAuthResponse = AuthResponse(
      user: User(
        id: 'uu',
        appMetadata: {},
        userMetadata: {},
        aud: faker.randomGenerator.string(5),
        createdAt: faker.date.dateTime().toIso8601String(),
      ),
    );
  });

  group('login', () {
    const tAuthenticationRequest = AuthenticationModel(
      username: 'test@example.com',
      password: 'password',
    );

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
            email: tAuthenticationRequest.username,
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

  group('resetPassword', () {
    test('should return SuccessState when reset email is sent', () async {
      // Arrange
      when(
        () => mockSupabaseAuthClient.resetPasswordForEmail(any()),
      ).thenAnswer((_) async {});

      // Act
      final result = await dataSource.resetPassword('test@example.com');

      // Assert
      expect(result, isA<SuccessState<void>>());
      verify(
        () => mockSupabaseAuthClient.resetPasswordForEmail('test@example.com'),
      ).called(1);
    });

    test('should return FailureState when reset fails', () async {
      // Arrange
      when(
        () => mockSupabaseAuthClient.resetPasswordForEmail(any()),
      ).thenThrow(const AuthException('Error sending email'));

      // Act
      final result = await dataSource.resetPassword('test@example.com');

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
