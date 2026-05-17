import 'package:clean_architecture/core/data/models/responses/user_model.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:clean_architecture/features/auth/data/repositories/session_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';

void main() {
  late MockSessionLocalDataSource mockSessionLocalDataSource;
  late SessionRepositoryImpl sessionRepository;

  setUp(() {
    mockSessionLocalDataSource = MockSessionLocalDataSource();
    sessionRepository = SessionRepositoryImpl(
      localDataSource: mockSessionLocalDataSource,
    );
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
          ..clearSessionData();

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
        // Act
        sessionRepository.setUserData = userData;

        // Assert
        expect(sessionRepository.isLoggedIn, isTrue);
        expect(sessionRepository.userData, equals(userData));
      });
    });
  });
}
