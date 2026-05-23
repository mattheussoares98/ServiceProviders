import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';
import 'package:clean_architecture/features/auth/domain/repositories/session_repository.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/login_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit_use_cases.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/helpers/test_factory.dart';
import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/external/router_mocks.dart';
import '../../../../../../testing/mocks/repository_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

final locator = GetIt.I;

class MockNavigatorKey extends Mock implements GlobalKey<NavigatorState> {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockLogOutUseCase mockLogOutUseCase;
  late MockSessionRepository mockSessionRepository;
  late MockNavigationClient mockNavigationClient;
  late MockResetPasswordUseCase mockResetPasswordUseCase;
  late LoginCubit loginCubit;
  late UserDataEntity userData;

  setUpAll(() {
    userData = TestFactory.makeUserDataEntity().copyWith(
      user: TestFactory.makeUserEntity().copyWith(
        id: '',
        firstName: '',
        lastName: '',
        username: '',
        email: '',
        isActive: true,
      ),
      accessToken: '',
      refreshToken: '',
    );
    registerFallbackValue(
      const AuthenticationEntity(username: '', password: ''),
    );
    registerFallbackValue(const MockPageRouteInfo());
    registerFallbackValue(userData);
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogOutUseCase = MockLogOutUseCase();
    mockSessionRepository = MockSessionRepository();
    mockNavigationClient = MockNavigationClient();
    final mockNavigatorKey = MockNavigatorKey();
    when(() => mockNavigatorKey.currentState).thenReturn(null);
    when(() => mockNavigationClient.navigatorKey).thenReturn(mockNavigatorKey);
    mockResetPasswordUseCase = MockResetPasswordUseCase();

    locator
      ..registerSingleton<LoginUseCase>(mockLoginUseCase)
      ..registerSingleton<LogOutUseCase>(mockLogOutUseCase)
      ..registerSingleton<SessionRepository>(mockSessionRepository)
      ..registerSingleton<NavigationClient>(mockNavigationClient)
      ..registerSingleton<ResetPasswordUseCase>(mockResetPasswordUseCase);

    final useCases = LoginCubitUseCases(
      login: mockLoginUseCase,
      logOut: mockLogOutUseCase,
      resetPassword: GetIt.I<ResetPasswordUseCase>(),
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
      when(() => mockNavigationClient.replaceAllRoute(any())).thenAnswer((
        _,
      ) async {});
      when(
        () => mockLoginUseCase.call(any()),
      ).thenAnswer((_) async => SuccessState(data: userData));

      return loginCubit;
    },
    act: (cubit) async {
      await cubit.login(
        username: faker.internet.userName(),
        password: faker.internet.password(),
      );
    },
    verify: (_) {
      verify(() => mockLoginUseCase.call(any())).called(1);
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
        username: faker.internet.userName(),
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
    build: () {
      when(
        () => mockNavigationClient.pushRoute(any()),
      ).thenAnswer((_) => Future.value());
      when(
        () => mockNavigationClient.pushRoute<void>(any()),
      ).thenAnswer((_) => Future.value());
      when(
        () => mockNavigationClient.pushRoute<dynamic>(any()),
      ).thenAnswer((_) => Future.value());
      return loginCubit;
    },
    act: (cubit) => cubit.navigateToSignUp(),
    verify: (_) {
      verify(() => mockNavigationClient.pushRoute<void>(any())).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'resetPassword should call resetPassword use case',
    build: () {
      when(
        () => mockResetPasswordUseCase.call(any()),
      ).thenAnswer((_) async => SuccessState.nil);
      return loginCubit;
    },
    act: (cubit) => cubit.resetPassword(faker.internet.email()),
    verify: (_) {
      verify(() => mockResetPasswordUseCase.call(any())).called(1);
    },
  );
}
