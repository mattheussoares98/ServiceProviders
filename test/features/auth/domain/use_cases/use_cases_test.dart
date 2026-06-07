import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/login_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  // Use cases
  late LoginUseCase loginUseCase;
  late SignUpUseCase signUpUseCase;
  late ChangePasswordUseCase changePasswordUseCase;

  setUpAll(() {
    registerFallbackValue(const AuthenticationEntity(email: '', password: ''));
    registerFallbackValue(const SignUpEntity(name: '', email: '', password: ''));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(authRepository: mockAuthRepository);
    signUpUseCase = SignUpUseCase(authRepository: mockAuthRepository);
    changePasswordUseCase = ChangePasswordUseCase(repository: mockAuthRepository);
  });

  // Test data
  final tAuthentication = EntityFactory.makeAuthentication().copyWith(
    username: 'test',
    password: 'password',
  );
  final tUserData = EntityFactory.makeUserDataEntity().copyWith(
    user: EntityFactory.makeUserEntity(),
  );
  final tSignUpEntity = EntityFactory.makeSignUp();
  final tNewPassword = faker.internet.password();

  group('Auth Use Cases', () {
    group('LoginUseCase', () {
      test('should call authRepository.login and return user data on success', () async {
        // Arrange
        when(() => mockAuthRepository.login(any()))
            .thenAnswer((_) async => SuccessState(data: tUserData));

        // Act
        final result = await loginUseCase(tAuthentication);

        // Assert
        expect(result, isA<SuccessState<UserDataEntity>>());
        expect(result.data, tUserData);
        verify(() => mockAuthRepository.login(tAuthentication)).called(1);
      });

      test('should return a FailureState when the repository call fails', () async {
        // Arrange
        final tFailureState = FailureState<UserDataEntity>(message: 'Login Failed');
        when(() => mockAuthRepository.login(any())).thenAnswer((_) async => tFailureState);

        // Act
        final result = await loginUseCase(tAuthentication);

        // Assert
        expect(result, isA<FailureState<UserDataEntity>>());
        expect(result.message, 'Login Failed');
        verify(() => mockAuthRepository.login(tAuthentication)).called(1);
      });
    });

    group('SignUpUseCase', () {
      test('should call authRepository.signUp and return user data on success', () async {
        // Arrange
        when(() => mockAuthRepository.signUp(any()))
            .thenAnswer((_) async => SuccessState(data: tUserData));

        // Act
        final result = await signUpUseCase(tSignUpEntity);

        // Assert
        expect(result, isA<SuccessState<UserDataEntity>>());
        expect(result.data, tUserData);
        verify(() => mockAuthRepository.signUp(tSignUpEntity)).called(1);
      });

      test('should return a FailureState when the repository call fails', () async {
        // Arrange
        final tErrorMessage = faker.lorem.sentence();
        final tFailureState = FailureState<UserDataEntity>(message: tErrorMessage);
        when(() => mockAuthRepository.signUp(any())).thenAnswer((_) async => tFailureState);

        // Act
        final result = await signUpUseCase(tSignUpEntity);

        // Assert
        expect(result, isA<FailureState<UserDataEntity>>());
        expect(result.message, tErrorMessage);
        verify(() => mockAuthRepository.signUp(tSignUpEntity)).called(1);
      });
    });

    group('ChangePasswordUseCase', () {
      test('should call authRepository.changePassword and return SuccessState on success', () async {
        // Arrange
        when(() => mockAuthRepository.changePassword(any()))
            .thenAnswer((_) async => SuccessState.nil);

        // Act
        final result = await changePasswordUseCase(tNewPassword);

        // Assert
        expect(result, isA<SuccessState<void>>());
        verify(() => mockAuthRepository.changePassword(tNewPassword)).called(1);
      });

      test('should return a FailureState when the repository call fails', () async {
        // Arrange
        final tFailureState = FailureState<void>(message: 'Failed to update password');
        when(() => mockAuthRepository.changePassword(any())).thenAnswer((_) async => tFailureState);

        // Act
        final result = await changePasswordUseCase(tNewPassword);

        // Assert
        expect(result, isA<FailureState<void>>());
        expect(result.message, 'Failed to update password');
        verify(() => mockAuthRepository.changePassword(tNewPassword)).called(1);
      });
    });
  });
}
