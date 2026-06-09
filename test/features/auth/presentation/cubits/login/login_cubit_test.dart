import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';
import 'package:clean_architecture/features/auth/domain/repositories/session_repository.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/get_user_data_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/login_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit_use_cases.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/external/router_mocks.dart';
import '../../../../../../testing/mocks/repository_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

final locator = GetIt.I;

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockLogOutUseCase mockLogOutUseCase;
  late MockSessionRepository mockSessionRepository;
  late MockNavigationClient mockNavigationClient;
  late MockResetPasswordUseCase mockResetPasswordUseCase;
  late MockSetSessionUseCase mockSetSessionUseCase;
  late LoginCubit loginCubit;
  late UserDataEntity userData;
  late MockGetUserDataUseCase mockGetUserDataUseCase;
  late MockSaveUserDataUseCase mockSaveUserDataUseCase;

  setUpAll(() {
    userData = EntityFactory.makeUserDataEntity().copyWith(
      user: EntityFactory.makeUserProfileEntity(),
    );
    registerFallbackValue(const AuthenticationEntity(email: '', password: ''));
    registerFallbackValue(const MockPageRouteInfo());
    registerFallbackValue(userData);
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogOutUseCase = MockLogOutUseCase();
    mockSessionRepository = MockSessionRepository();
    mockNavigationClient = MockNavigationClient();
    mockResetPasswordUseCase = MockResetPasswordUseCase();
    mockSetSessionUseCase = MockSetSessionUseCase();
    mockGetUserDataUseCase = MockGetUserDataUseCase();
    mockSaveUserDataUseCase = MockSaveUserDataUseCase();

    locator
      ..registerSingleton<LoginUseCase>(mockLoginUseCase)
      ..registerSingleton<LogOutUseCase>(mockLogOutUseCase)
      ..registerSingleton<SessionRepository>(mockSessionRepository)
      ..registerSingleton<NavigationClient>(mockNavigationClient)
      ..registerSingleton<ResetPasswordUseCase>(mockResetPasswordUseCase)
      ..registerSingleton<SetSessionUseCase>(mockSetSessionUseCase)
      ..registerSingleton<SaveUserDataUseCase>(mockSaveUserDataUseCase)
      ..registerSingleton<GetUserDataUseCase>(mockGetUserDataUseCase);

    final useCases = LoginCubitUseCases(
      login: mockLoginUseCase,
      logOut: mockLogOutUseCase,
      resetPassword: GetIt.I<ResetPasswordUseCase>(),
      setSession: mockSetSessionUseCase,
      getUserData: mockGetUserDataUseCase,
      saveUserData: mockSaveUserDataUseCase,
    );
    loginCubit = LoginCubit(useCases: useCases);
  });

  tearDown(locator.reset);

  blocTest<LoginCubit, LoginState>(
    'togglePasswordVisibility should flip passwordVisibility state',
    build: () => loginCubit,
    act: (cubit) => cubit.togglePasswordVisibility(),
    expect: () => [const LoginState(passwordVisibility: true)],
  );

  blocTest<LoginCubit, LoginState>(
    'login should call login use case and navigate on success',
    build: () {
      when(
        () => mockLoginUseCase.call(any()),
      ).thenAnswer((_) async => SuccessState(data: userData));
      when(() => mockSetSessionUseCase.call(any())).thenReturn(null);
      when(
        () => mockSaveUserDataUseCase.call(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      return loginCubit;
    },
    act: (cubit) async {
      await cubit.login(
        email: faker.internet.userName(),
        password: faker.internet.password(),
      );
    },
    verify: (_) {
      verify(() => mockLoginUseCase.call(any())).called(1);
      verify(() => mockSetSessionUseCase.call(any())).called(1);
      verify(() => mockSaveUserDataUseCase.call(any())).called(1);
      verify(() => mockNavigationClient.replaceAllRoute(any())).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'login should not navigate and emit loaded state on failure',
    build: () {
      when(
        () => mockLoginUseCase.call(any()),
      ).thenAnswer((_) async => FailureState(message: 'Login failed'));

      return loginCubit;
    },
    act: (cubit) async {
      await cubit.login(
        email: faker.internet.userName(),
        password: faker.internet.password(),
      );
    },
    expect: () => [
      isA<LoginState>().having((s) => s.status, 'status', StateStatus.loading),
      isA<LoginState>().having((s) => s.status, 'status', StateStatus.loaded),
    ],
    verify: (_) {
      verify(() => mockLoginUseCase.call(any())).called(1);
      verifyNever(() => mockNavigationClient.replaceAllRoute(any()));
    },
  );

  blocTest<LoginCubit, LoginState>(
    'navigateToSignUp should call pushRoute with SignUpRoute',
    build: () => loginCubit,
    act: (cubit) => cubit.navigateToSignUp(),
    verify: (_) {
      verify(() => mockNavigationClient.pushRoute<void>(any())).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'resetPassword should call resetPassword use case and emit success states',
    build: () {
      when(
        () => mockResetPasswordUseCase.call(any()),
      ).thenAnswer((_) async => SuccessState.nil);
      return loginCubit;
    },
    act: (cubit) => cubit.resetPassword(faker.internet.email()),
    expect: () => [
      isA<LoginState>()
          .having(
            (s) => s.resetPasswordStatus,
            'resetPasswordStatus',
            StateStatus.loading,
          )
          .having((s) => s.status, 'status', StateStatus.initial),
      isA<LoginState>()
          .having(
            (s) => s.resetPasswordStatus,
            'resetPasswordStatus',
            StateStatus.loaded,
          )
          .having((s) => s.status, 'status', StateStatus.initial),
    ],
    verify: (_) {
      verify(() => mockResetPasswordUseCase.call(any())).called(1);
      verify(() => mockNavigationClient.maybePop()).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'resetPassword should call resetPassword use case and emit loaded state on failure',
    build: () {
      when(
        () => mockResetPasswordUseCase.call(any()),
      ).thenAnswer((_) async => FailureState(message: 'Error'));
      return loginCubit;
    },
    act: (cubit) => cubit.resetPassword(faker.internet.email()),
    expect: () => [
      isA<LoginState>()
          .having(
            (s) => s.resetPasswordStatus,
            'resetPasswordStatus',
            StateStatus.loading,
          )
          .having((s) => s.status, 'status', StateStatus.initial),
      isA<LoginState>()
          .having(
            (s) => s.resetPasswordStatus,
            'resetPasswordStatus',
            StateStatus.loaded,
          )
          .having((s) => s.status, 'status', StateStatus.initial),
    ],
    verify: (_) {
      verify(() => mockResetPasswordUseCase.call(any())).called(1);
      verify(() => mockNavigationClient.maybePop()).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'getUserData should call getUserData use case and emit state with userData on success',
    build: () {
      when(
        () => mockGetUserDataUseCase.call(),
      ).thenAnswer((_) async => SuccessState(data: userData));
      return loginCubit;
    },
    act: (cubit) => cubit.getUserData(),
    expect: () => [
      isA<LoginState>().having((s) => s.userData, 'userData', userData),
    ],
    verify: (_) {
      verify(() => mockGetUserDataUseCase.call()).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'getUserData should call getUserData use case and not emit state on failure',
    build: () {
      when(
        () => mockGetUserDataUseCase.call(),
      ).thenAnswer((_) async => FailureState(message: 'Error'));
      return loginCubit;
    },
    act: (cubit) => cubit.getUserData(),
    expect: () => <LoginState>[],
    verify: (_) {
      verify(() => mockGetUserDataUseCase.call()).called(1);
    },
  );

  group('clearSession', () {
    blocTest<LoginCubit, LoginState>(
      'should call logOut with email and name when getUserData returns SuccessState',
      build: () {
        when(
          () => mockGetUserDataUseCase.call(),
        ).thenAnswer((_) async => SuccessState(data: userData));
        when(
          () => mockLogOutUseCase.call(
            email: any(named: 'email'),
            name: any(named: 'name'),
          ),
        ).thenAnswer((_) async {});
        return loginCubit;
      },
      act: (cubit) => cubit.clearSession(),
      expect: () => <LoginState>[],
      verify: (_) {
        verify(() => mockGetUserDataUseCase.call()).called(1);
        verify(
          () => mockLogOutUseCase.call(
            email: userData.user.email,
            name: userData.user.name,
          ),
        ).called(1);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'should not call logOut when getUserData returns FailureState',
      build: () {
        when(
          () => mockGetUserDataUseCase.call(),
        ).thenAnswer((_) async => FailureState(message: 'Error'));
        return loginCubit;
      },
      act: (cubit) => cubit.clearSession(),
      expect: () => <LoginState>[],
      verify: (_) {
        verify(() => mockGetUserDataUseCase.call()).called(1);
        verifyNever(
          () => mockLogOutUseCase.call(
            email: any(named: 'email'),
            name: any(named: 'name'),
          ),
        );
      },
    );
  });
}
