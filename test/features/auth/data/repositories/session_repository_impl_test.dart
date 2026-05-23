import 'package:clean_architecture/core/data/models/responses/user_model.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:clean_architecture/features/auth/data/repositories/session_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/external/external_mocks.dart';

// ignore: avoid_implementing_value_types
class MockSession extends Mock implements Session {}

void main() {
  late MockSessionLocalDataSource mockSessionLocalDataSource;
  late MockSupabaseAuthClient mockSupabaseAuthClient;
  late SessionRepositoryImpl sessionRepository;

  setUp(() {
    mockSessionLocalDataSource = MockSessionLocalDataSource();
    mockSupabaseAuthClient = MockSupabaseAuthClient();
    sessionRepository = SessionRepositoryImpl(
      localDataSource: mockSessionLocalDataSource,
      auth: mockSupabaseAuthClient,
    );
    when(() => mockSupabaseAuthClient.currentSession).thenReturn(null);
  });

  final userDataResponse = UserDataResponseModel(
    user: UserModel.fromEntity(
      TestFactory.makeUserEntity().copyWith(
        id: '1',
        firstName: 'Test',
        lastName: 'User',
        username: 'testuser',
        email: 'test@example.com',
        isActive: true,
      ),
    ),
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
  );

  final userData = userDataResponse.toEntity();

  group('SessionRepositoryImpl', () {
    group('checkForUserCredential', () {
      test(
        'should call getUserData and update userData when cached data exists',
        () async {
          // Arrange
          final mockSession = MockSession();
          when(() => mockSession.accessToken).thenReturn('access_token');
          when(
            () => mockSupabaseAuthClient.currentSession,
          ).thenReturn(mockSession);

          when(
            () => mockSessionLocalDataSource.getUserData(),
          ).thenAnswer((_) async => userDataResponse);

          // Act
          await sessionRepository.checkForUserCredential();

          // Assert
          verify(() => mockSessionLocalDataSource.getUserData()).called(1);
          expect(sessionRepository.isLoggedIn, isTrue);
          expect(sessionRepository.userData, equals(userData));
        },
      );

      test(
        'should call getUserData and do nothing when cached data is null',
        () async {
          // Arrange
          when(
            () => mockSessionLocalDataSource.getUserData(),
          ).thenAnswer((_) async => null);

          // Act
          await sessionRepository.checkForUserCredential();

          // Assert
          verify(() => mockSessionLocalDataSource.getUserData()).called(1);
          expect(sessionRepository.isLoggedIn, isFalse);
          expect(
            sessionRepository.userData,
            equals(const UserDataEntity.empty()),
          );
        },
      );
    });

    group('clearSessionData', () {
      test('should call clearUserData and reset local state', () {
        // Arrange
        when(
          () => mockSessionLocalDataSource.clearUserData(),
        ).thenAnswer((_) async {});

        // Set some initial state
        sessionRepository
          ..setUserData = userData
          // Act
          ..logout();

        // Assert
        verify(() => mockSessionLocalDataSource.clearUserData()).called(1);
        expect(sessionRepository.isLoggedIn, isFalse);
        expect(
          sessionRepository.userData,
          equals(const UserDataEntity.empty()),
        );
      });
    });

    group('setUserData', () {
      test('should update local userData', () {
        // Arrange
        final mockSession = MockSession();
        when(() => mockSession.accessToken).thenReturn('access_token');
        when(
          () => mockSupabaseAuthClient.currentSession,
        ).thenReturn(mockSession);

        // Act
        sessionRepository.setUserData = userData;

        // Assert
        expect(sessionRepository.isLoggedIn, isTrue);
        expect(sessionRepository.userData, equals(userData));
      });
    });
  });
}
