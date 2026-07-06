import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:o_jogo_da_obra/features/auth/data/repositories/session_repository_impl.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/external/external_mocks.dart';

// ignore: avoid_implementing_value_types
class MockSession extends Mock implements Session {}

// ignore: avoid_implementing_value_types
class MockUser extends Mock implements User {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      UserDataResponseModel.fromEntity(EntityFactory.makeUserDataEntity()),
    );
  });

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
    when(() => mockSupabaseAuthClient.logout()).thenAnswer((_) async {});
  });

  final userDataResponse = UserDataResponseModel(
    user: UserProfileResponseModel.fromEntity(
      EntityFactory.makeUserProfileEntity(),
    ),
    accessToken: faker.lorem.word(),
    refreshToken: faker.lorem.word(),
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
          expect(sessionRepository.userData, equals(UserDataEntity.empty()));
        },
      );

      test(
        'should not hydrate session from Supabase when cached profile data is null',
        () async {
          // Arrange
          final mockSession = MockSession();
          final accessToken = faker.lorem.word();

          when(() => mockSession.accessToken).thenReturn(accessToken);

          when(
            () => mockSupabaseAuthClient.currentSession,
          ).thenReturn(mockSession);
          when(
            () => mockSessionLocalDataSource.getUserData(),
          ).thenAnswer((_) async => null);

          // Act
          await sessionRepository.checkForUserCredential();

          // Assert
          verify(() => mockSessionLocalDataSource.getUserData()).called(1);
          verifyNever(() => mockSessionLocalDataSource.saveUserData(any()));
          expect(sessionRepository.isLoggedIn, isFalse);
          expect(sessionRepository.userData, equals(UserDataEntity.empty()));
        },
      );

      test(
        'should emit updated userData on sessionStream when cached data exists',
        () async {
          final mockSession = MockSession();
          when(() => mockSession.accessToken).thenReturn('access_token');
          when(
            () => mockSupabaseAuthClient.currentSession,
          ).thenReturn(mockSession);
          when(
            () => mockSessionLocalDataSource.getUserData(),
          ).thenAnswer((_) async => userDataResponse);

          unawaited(
            expectLater(
              sessionRepository.sessionStream,
              emitsThrough(userData),
            ),
          );

          await sessionRepository.checkForUserCredential();
        },
      );
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

      test('should emit updated userData on sessionStream', () {
        final mockSession = MockSession();
        when(() => mockSession.accessToken).thenReturn('access_token');
        when(
          () => mockSupabaseAuthClient.currentSession,
        ).thenReturn(mockSession);

        unawaited(
          expectLater(sessionRepository.sessionStream, emitsThrough(userData)),
        );

        sessionRepository.setUserData = userData;
      });
    });

    group('Logout', () {
      test('should clean IDs, permission and tokens on logout', () async {
        registerFallbackValue(
          UserDataResponseModel.fromEntity(EntityFactory.makeUserDataEntity()),
        );
        when(
          () => mockSessionLocalDataSource.getUserData(),
        ).thenAnswer((_) async => userDataResponse);
        when(() => mockSupabaseAuthClient.logout()).thenAnswer((_) async {});
        final mockSession = MockSession();
        when(() => mockSession.accessToken).thenReturn('');
        when(
          () => mockSessionLocalDataSource.saveUserData(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockSupabaseAuthClient.currentSession,
        ).thenReturn(mockSession);

        //load the user first
        await sessionRepository.checkForUserCredential();
        await sessionRepository.logout();

        final cleanedUser = UserDataEntity.empty().copyWith(
          user: userDataResponse.user.copyWith(
            email: userDataResponse.user.email,
          ),
        );
        verify(() => mockSupabaseAuthClient.logout()).called(1);
        verify(
          () => mockSessionLocalDataSource.saveUserData(
            UserDataResponseModel.fromEntity(cleanedUser),
          ),
        ).called(1);

        expect(sessionRepository.isLoggedIn, isFalse);
        expect(sessionRepository.userData, equals(cleanedUser));
      });

      test('should emit empty userData on sessionStream', () async {
        registerFallbackValue(
          UserDataResponseModel.fromEntity(EntityFactory.makeUserDataEntity()),
        );
        when(() => mockSupabaseAuthClient.logout()).thenAnswer((_) async {});
        final mockSession = MockSession();
        when(() => mockSession.accessToken).thenReturn('');
        when(
          () => mockSessionLocalDataSource.saveUserData(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockSupabaseAuthClient.currentSession,
        ).thenReturn(mockSession);

        unawaited(
          expectLater(
            sessionRepository.sessionStream,
            emitsThrough(UserDataEntity.empty()),
          ),
        );

        await sessionRepository.logout();
      });
    });
  });
}
