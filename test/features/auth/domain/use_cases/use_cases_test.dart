import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/login_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/watch_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/watch_session_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSessionRepository mockSessionRepository;

  // Use cases
  late LoginUseCase loginUseCase;
  late SignUpUseCase signUpUseCase;
  late ChangePasswordUseCase changePasswordUseCase;
  late SaveUserDataUseCase saveUserDataUseCase;
  late WatchSessionUseCase watchSessionUseCase;
  late GetAuthUserUseCase getAuthUserUseCase;
  late WatchAuthUserUseCase watchAuthUserUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeAuthentication());
    registerFallbackValue(EntityFactory.makeSignUp());
    registerFallbackValue(EntityFactory.makeUserDataEntity());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSessionRepository = MockSessionRepository();
    loginUseCase = LoginUseCase(authRepository: mockAuthRepository);
    signUpUseCase = SignUpUseCase(authRepository: mockAuthRepository);
    changePasswordUseCase = ChangePasswordUseCase(
      repository: mockAuthRepository,
    );
    saveUserDataUseCase = SaveUserDataUseCase(mockAuthRepository);
    watchSessionUseCase = WatchSessionUseCase(
      sessionRepository: mockSessionRepository,
    );
    getAuthUserUseCase = GetAuthUserUseCase(authRepository: mockAuthRepository);
    watchAuthUserUseCase = WatchAuthUserUseCase(
      authRepository: mockAuthRepository,
    );
  });

  // Test data
  final tAuthentication = EntityFactory.makeAuthentication().copyWith(
    username: 'test',
    password: 'password',
  );
  final tUserData = EntityFactory.makeUserDataEntity().copyWith(
    user: EntityFactory.makeUserProfileEntity(),
  );
  final tSignUpEntity = EntityFactory.makeSignUp();
  final tNewPassword = faker.internet.password();

  group('Auth Use Cases', () {
    group('LoginUseCase', () {
      test(
        'should call authRepository.login and return user data on success',
        () async {
          // Arrange
          when(
            () => mockAuthRepository.login(any()),
          ).thenAnswer((_) async => SuccessState(data: tUserData));

          // Act
          final result = await loginUseCase(tAuthentication);

          // Assert
          expect(result, isA<SuccessState<UserDataEntity>>());
          expect(result.data, tUserData);
          verify(() => mockAuthRepository.login(tAuthentication)).called(1);
        },
      );

      test(
        'should return a FailureState when the repository call fails',
        () async {
          // Arrange
          final tFailureState = FailureState<UserDataEntity>(
            message: 'Login Failed',
          );
          when(
            () => mockAuthRepository.login(any()),
          ).thenAnswer((_) async => tFailureState);

          // Act
          final result = await loginUseCase(tAuthentication);

          // Assert
          expect(result, isA<FailureState<UserDataEntity>>());
          expect(result.message, 'Login Failed');
          verify(() => mockAuthRepository.login(tAuthentication)).called(1);
        },
      );
    });

    group('SignUpUseCase', () {
      test(
        'should call authRepository.signUp and return user data on success',
        () async {
          // Arrange
          when(
            () => mockAuthRepository.signUp(any()),
          ).thenAnswer((_) async => SuccessState(data: tUserData));

          // Act
          final result = await signUpUseCase(tSignUpEntity);

          // Assert
          expect(result, isA<SuccessState<UserDataEntity>>());
          expect(result.data, tUserData);
          verify(() => mockAuthRepository.signUp(tSignUpEntity)).called(1);
        },
      );

      test(
        'should return a FailureState when the repository call fails',
        () async {
          // Arrange
          final tErrorMessage = faker.lorem.sentence();
          final tFailureState = FailureState<UserDataEntity>(
            message: tErrorMessage,
          );
          when(
            () => mockAuthRepository.signUp(any()),
          ).thenAnswer((_) async => tFailureState);

          // Act
          final result = await signUpUseCase(tSignUpEntity);

          // Assert
          expect(result, isA<FailureState<UserDataEntity>>());
          expect(result.message, tErrorMessage);
          verify(() => mockAuthRepository.signUp(tSignUpEntity)).called(1);
        },
      );
    });

    group('ChangePasswordUseCase', () {
      test(
        'should call authRepository.changePassword and return SuccessState on success',
        () async {
          // Arrange
          when(
            () => mockAuthRepository.changePassword(any()),
          ).thenAnswer((_) async => SuccessState.nil);

          // Act
          final result = await changePasswordUseCase(tNewPassword);

          // Assert
          expect(result, isA<SuccessState<void>>());
          verify(
            () => mockAuthRepository.changePassword(tNewPassword),
          ).called(1);
        },
      );

      test(
        'should return a FailureState when the repository call fails',
        () async {
          // Arrange
          final tFailureState = FailureState<void>(
            message: 'Failed to update password',
          );
          when(
            () => mockAuthRepository.changePassword(any()),
          ).thenAnswer((_) async => tFailureState);

          // Act
          final result = await changePasswordUseCase(tNewPassword);

          // Assert
          expect(result, isA<FailureState<void>>());
          expect(result.message, 'Failed to update password');
          verify(
            () => mockAuthRepository.changePassword(tNewPassword),
          ).called(1);
        },
      );
    });

    group('SaveUserDataUseCase', () {
      test(
        'should call authRepository.saveUserData and return SuccessState on success',
        () async {
          // Arrange
          when(
            () => mockAuthRepository.saveUserData(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await saveUserDataUseCase(tUserData);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, true);
          verify(() => mockAuthRepository.saveUserData(tUserData)).called(1);
        },
      );

      test(
        'should return a FailureState when the repository call fails',
        () async {
          // Arrange
          final tFailureState = FailureState<void>(
            message: 'Failed to save user data',
          );
          when(() => mockAuthRepository.saveUserData(any())).thenAnswer(
            (_) async => FailureState(message: tFailureState.message),
          );

          // Act
          final result = await saveUserDataUseCase(tUserData);

          // Assert
          expect(result, isA<FailureState<bool>>());
          expect(result.message, 'Failed to save user data');
          verify(() => mockAuthRepository.saveUserData(tUserData)).called(1);
        },
      );
    });

    group('WatchSessionUseCase', () {
      test('should return session stream from sessionRepository', () {
        final stream = Stream<UserDataEntity>.value(tUserData);
        when(
          () => mockSessionRepository.sessionStream,
        ).thenAnswer((_) => stream);

        final result = watchSessionUseCase();

        expect(result, equals(stream));
        verify(() => mockSessionRepository.sessionStream).called(1);
      });
    });

    group('GetAuthUserUseCase', () {
      test('should return currentAuthUser from authRepository', () {
        final tAuthUser = EntityFactory.makeAuthUserEntity();
        when(() => mockAuthRepository.currentAuthUser).thenReturn(tAuthUser);

        final result = getAuthUserUseCase();

        expect(result, equals(tAuthUser));
        verify(() => mockAuthRepository.currentAuthUser).called(1);
      });
    });

    group('WatchAuthUserUseCase', () {
      test('should return authUserIdStream from authRepository', () {
        final stream = Stream<String?>.value(faker.guid.guid());
        when(
          () => mockAuthRepository.authUserIdStream,
        ).thenAnswer((_) => stream);

        final result = watchAuthUserUseCase();

        expect(result, equals(stream));
        verify(() => mockAuthRepository.authUserIdStream).called(1);
      });
    });
  });
}
