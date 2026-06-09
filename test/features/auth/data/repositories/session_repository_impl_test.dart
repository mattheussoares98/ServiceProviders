import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:clean_architecture/features/auth/data/repositories/session_repository_impl.dart';
import 'package:clean_architecture/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
      UserDataResponseModel(
        user: UserProfileResponseModel(
          id: '',
          companyId: '',
          name: '',
          email: '',
          isActive: false,
          createdAt: DateTime(0),
          updatedAt: DateTime(0),
        ),
        accessToken: '',
        refreshToken: '',
      ),
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

    group('Logout', () {
      test(
        'should call logout and save partial session data with email',
        () async {
          final email = faker.internet.email();
          final name = faker.person.name();

          registerFallbackValue(
            UserDataResponseModel.fromEntity(
              EntityFactory.makeUserDataEntity(),
            ),
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

          await sessionRepository.logout(email: email, name: name);

          verify(() => mockSupabaseAuthClient.logout()).called(1);
          verify(
            () => mockSessionLocalDataSource.saveUserData(
              UserDataResponseModel.fromEntity(
                UserDataEntity.empty().copyWith(
                  user: UserProfileEntity.empty().copyWith(
                    email: email,
                    name: name,
                  ),
                ),
              ),
            ),
          ).called(1);

          expect(sessionRepository.isLoggedIn, isFalse);
          expect(sessionRepository.userData, equals(UserDataEntity.empty()));
        },
      );
    });
  });
}
