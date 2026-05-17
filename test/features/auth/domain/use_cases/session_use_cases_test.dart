import 'package:clean_architecture/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockSessionRepository mockSessionRepository;
  late LogOutUseCase logOutUseCase;
  late SetSessionUseCase setSessionUseCase;

  setUp(() {
    mockSessionRepository = MockSessionRepository();
    logOutUseCase = LogOutUseCase(mockSessionRepository);
    setSessionUseCase = SetSessionUseCase(mockSessionRepository);
  });

  final userData = TestFactory.makeUserDataEntity().copyWith(
    user: TestFactory.makeUserEntity().copyWith(
      id: '1',
      firstName: 'Test',
      lastName: 'User',
      username: 'testuser',
      email: 'test@example.com',
      isActive: true,
    ),
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
  );

  group('Session Use Cases', () {
    group('LogOutUseCase', () {
      test('should call clearSessionData on repository', () {
        // Arrange
        when(() => mockSessionRepository.clearSessionData()).thenAnswer((_) {});

        // Act
        logOutUseCase();

        // Assert
        verify(() => mockSessionRepository.clearSessionData()).called(1);
      });
    });

    group('SetSessionUseCase', () {
      test('should call setUserData on repository', () {
        // Arrange
        when(
          () => mockSessionRepository.setUserData = userData,
        ).thenReturn(userData);

        // Act
        setSessionUseCase(userData);

        // Assert
        verify(() => mockSessionRepository.setUserData = userData).called(1);
      });
    });
  });
}
