import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/login_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/set_selected_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/watch_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/watch_session_use_case.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSessionRepository mockSessionRepository;
  late MockLocalStorageClient mockLocalStorageClient;

  // Use cases
  late LoginUseCase loginUseCase;
  late SignUpUseCase signUpUseCase;
  late ChangePasswordUseCase changePasswordUseCase;
  late SaveUserDataUseCase saveUserDataUseCase;
  late WatchSessionUseCase watchSessionUseCase;
  late GetAuthUserUseCase getAuthUserUseCase;
  late WatchAuthUserUseCase watchAuthUserUseCase;
  late VerifyOtpUseCase verifyOtpUseCase;
  late GetActiveCompanyIdUseCase getActiveCompanyIdUseCase;
  late SetSelectedCompanyIdUseCase setSelectedCompanyIdUseCase;
  late SaveSelectedModeUseCase saveSelectedModeUseCase;
  late GetSelectedModeUseCase getSelectedModeUseCase;

  setUpAll(() {
    registerFallbackValue(UserFactory.makeAuthentication());
    registerFallbackValue(UserFactory.makeSignUp());
    registerFallbackValue(UserFactory.makeUserDataEntity());
    registerFallbackValue(UserFactory.makeVerifyOtpRequestEntity());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSessionRepository = MockSessionRepository();
    mockLocalStorageClient = MockLocalStorageClient();
    loginUseCase = LoginUseCase(authRepository: mockAuthRepository);
    signUpUseCase = SignUpUseCase(authRepository: mockAuthRepository);
    verifyOtpUseCase = VerifyOtpUseCase(authRepository: mockAuthRepository);
    changePasswordUseCase = ChangePasswordUseCase(
      repository: mockAuthRepository,
    );
    saveUserDataUseCase = SaveUserDataUseCase(mockAuthRepository);
    watchSessionUseCase = WatchSessionUseCase(
      sessionRepository: mockSessionRepository,
    );
    getAuthUserUseCase = GetAuthUserUseCase(
      sessionRepository: mockSessionRepository,
    );
    watchAuthUserUseCase = WatchAuthUserUseCase(
      sessionRepository: mockSessionRepository,
    );
    getActiveCompanyIdUseCase = GetActiveCompanyIdUseCase(
      sessionRepository: mockSessionRepository,
    );
    setSelectedCompanyIdUseCase = SetSelectedCompanyIdUseCase(
      sessionRepository: mockSessionRepository,
    );
    saveSelectedModeUseCase = SaveSelectedModeUseCase(mockLocalStorageClient);
    getSelectedModeUseCase = GetSelectedModeUseCase(mockLocalStorageClient);
  });

  // Test data
  final tAuthentication = UserFactory.makeAuthentication().copyWith(
    username: 'test',
    password: 'password',
  );
  final tUserData = UserFactory.makeUserDataEntity().copyWith(
    user: UserFactory.makeUserProfileEntity(),
  );
  final tSignUpEntity = UserFactory.makeSignUp();
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
      test('should return currentAuthUser from sessionRepository', () {
        final tAuthUser = UserFactory.makeAuthUserEntity();
        when(() => mockSessionRepository.currentAuthUser).thenReturn(tAuthUser);

        final result = getAuthUserUseCase();

        expect(result, equals(tAuthUser));
        verify(() => mockSessionRepository.currentAuthUser).called(1);
      });
    });

    group('WatchAuthUserUseCase', () {
      test('should return authUserIdStream from sessionRepository', () {
        final stream = Stream<String?>.value(faker.guid.guid());
        when(
          () => mockSessionRepository.authUserIdStream,
        ).thenAnswer((_) => stream);

        final result = watchAuthUserUseCase();

        expect(result, equals(stream));
        verify(() => mockSessionRepository.authUserIdStream).called(1);
      });
    });

    group('VerifyOtpUseCase', () {
      test(
        'should call authRepository.verifyOtp and return user data on success',
        () async {
          final tVerifyOtpRequest = UserFactory.makeVerifyOtpRequestEntity();
          when(
            () => mockAuthRepository.verifyOtp(any()),
          ).thenAnswer((_) async => SuccessState(data: tUserData));

          final result = await verifyOtpUseCase(tVerifyOtpRequest);

          expect(result, isA<SuccessState<UserDataEntity>>());
          expect(result.data, tUserData);
          verify(
            () => mockAuthRepository.verifyOtp(tVerifyOtpRequest),
          ).called(1);
        },
      );

      test(
        'should return a FailureState when authRepository.verifyOtp fails',
        () async {
          final tVerifyOtpRequest = UserFactory.makeVerifyOtpRequestEntity();
          final tFailureState = FailureState<UserDataEntity>(
            message: 'OTP verification failed',
          );
          when(
            () => mockAuthRepository.verifyOtp(any()),
          ).thenAnswer((_) async => tFailureState);

          final result = await verifyOtpUseCase(tVerifyOtpRequest);

          expect(result, isA<FailureState<UserDataEntity>>());
          expect(result.message, 'OTP verification failed');
          verify(
            () => mockAuthRepository.verifyOtp(tVerifyOtpRequest),
          ).called(1);
        },
      );
    });

    group('GetActiveCompanyIdUseCase', () {
      test(
        'should return selectedCompanyId from sessionRepository when user is super admin',
        () {
          final superAdminUser = tUserData.copyWith(
            user: tUserData.user.copyWith(email: 'mattheussbarosa98@gmail.com'),
          );
          when(
            () => mockSessionRepository.getSelectedMode(),
          ).thenReturn('internal');
          when(() => mockSessionRepository.userData).thenReturn(superAdminUser);
          when(
            () => mockSessionRepository.getSelectedCompanyId(),
          ).thenReturn('selected_comp_123');

          final result = getActiveCompanyIdUseCase();

          expect(result, 'selected_comp_123');
        },
      );

      test('should return user.companyId when selectedCompanyId is null', () {
        when(
          () => mockSessionRepository.getSelectedMode(),
        ).thenReturn('internal');
        when(() => mockSessionRepository.userData).thenReturn(tUserData);
        when(
          () => mockSessionRepository.getSelectedCompanyId(),
        ).thenReturn(null);

        final result = getActiveCompanyIdUseCase();

        expect(result, tUserData.user.companyId);
      });
    });

    group('SetSelectedCompanyIdUseCase', () {
      test('should call sessionRepository.setSelectedCompanyId', () async {
        when(
          () => mockSessionRepository.setSelectedCompanyId(any()),
        ).thenAnswer((_) async {});

        await setSelectedCompanyIdUseCase('new_comp_123');

        verify(
          () => mockSessionRepository.setSelectedCompanyId('new_comp_123'),
        ).called(1);
      });
    });

    group('SelectedModeUseCases', () {
      test(
        'SaveSelectedModeUseCase should call localStorageClient.saveSelectedMode with mode',
        () async {
          when(
            () => mockLocalStorageClient.saveSelectedMode(any()),
          ).thenAnswer((_) async {});

          await saveSelectedModeUseCase.call(AppMode.provider.name);

          verify(
            () =>
                mockLocalStorageClient.saveSelectedMode(AppMode.provider.name),
          ).called(1);
        },
      );

      test(
        'GetSelectedModeUseCase should return selected mode from localStorageClient',
        () {
          when(
            () => mockLocalStorageClient.getSelectedMode(),
          ).thenReturn(AppMode.provider.name);

          final result = getSelectedModeUseCase.call();

          expect(result, AppMode.provider.name);
          verify(() => mockLocalStorageClient.getSelectedMode()).called(1);
        },
      );
    });
  });
}
