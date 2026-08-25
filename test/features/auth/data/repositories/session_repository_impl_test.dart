import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/responses/user_data_model.dart';
import 'package:o_jogo_da_obra/features/auth/data/repositories/session_repository_impl.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_model.dart';
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
      UserDataModel.fromEntity(EntityFactory.makeUserDataEntity()),
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

  final userDataResponse = UserDataModel(
    user: UserProfileModel.fromEntity(EntityFactory.makeUserProfileEntity()),
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
          UserDataModel.fromEntity(EntityFactory.makeUserDataEntity()),
        );
        when(
          () => mockSessionLocalDataSource.getUserData(),
        ).thenAnswer((_) async => userDataResponse);
        when(() => mockSupabaseAuthClient.logout()).thenAnswer((_) async {});
        when(
          () => mockSessionLocalDataSource.clearSelectedMode(),
        ).thenAnswer((_) async {});
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
            UserDataModel.fromEntity(cleanedUser),
          ),
        ).called(1);
        verify(() => mockSessionLocalDataSource.clearSelectedMode()).called(1);

        expect(sessionRepository.isLoggedIn, isFalse);
        expect(sessionRepository.userData, equals(cleanedUser));
      });

      test('should emit empty userData on sessionStream', () async {
        registerFallbackValue(
          UserDataModel.fromEntity(EntityFactory.makeUserDataEntity()),
        );
        when(() => mockSupabaseAuthClient.logout()).thenAnswer((_) async {});
        when(
          () => mockSessionLocalDataSource.clearSelectedMode(),
        ).thenAnswer((_) async {});
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

    group('currentAuthUser', () {
      test('should return null when session is null', () {
        when(() => mockSupabaseAuthClient.currentSession).thenReturn(null);
        expect(sessionRepository.currentAuthUser, isNull);
      });

      test('should return AuthUserEntity when session is present', () {
        final mockUser = MockUser();
        final mockSession = MockSession();
        final userId = faker.guid.guid();
        final email = faker.internet.email();
        final name = faker.person.name();
        final nowStr = DateTime.now().toIso8601String();

        when(() => mockUser.id).thenReturn(userId);
        when(() => mockUser.email).thenReturn(email);
        when(() => mockUser.userMetadata).thenReturn({'name': name});
        when(() => mockUser.createdAt).thenReturn(nowStr);
        when(() => mockUser.updatedAt).thenReturn(nowStr);
        when(() => mockSession.user).thenReturn(mockUser);
        when(
          () => mockSupabaseAuthClient.currentSession,
        ).thenReturn(mockSession);

        final result = sessionRepository.currentAuthUser;
        expect(result, isNotNull);
        expect(result?.id, userId);
        expect(result?.email, email);
        expect(result?.name, name);
      });
    });

    group('authUserIdStream', () {
      test('should map AuthState stream to user id stream', () async {
        final userId = faker.guid.guid();
        final mockUser = MockUser();
        final mockSession = MockSession();
        when(() => mockUser.id).thenReturn(userId);
        when(() => mockSession.user).thenReturn(mockUser);

        final authState = AuthState(AuthChangeEvent.signedIn, mockSession);

        when(
          () => mockSupabaseAuthClient.onAuthStateChange,
        ).thenAnswer((_) => Stream.value(authState));

        final stream = sessionRepository.authUserIdStream;
        expect(await stream.first, userId);
      });
    });

    group('setSelectedCompanyId', () {
      test('should save to localDataSource and update session userData', () async {
        final newCompanyId = faker.guid.guid();
        when(
          () => mockSessionLocalDataSource.saveSelectedCompanyId(any()),
        ).thenAnswer((_) async {});

        sessionRepository.setUserData = userData;

        await sessionRepository.setSelectedCompanyId(newCompanyId);

        verify(
          () => mockSessionLocalDataSource.saveSelectedCompanyId(newCompanyId),
        ).called(1);
        expect(sessionRepository.userData.user.companyId, newCompanyId);
      });
    });
  });
}
