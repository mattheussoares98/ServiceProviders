import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user.dart';
import 'package:clean_architecture/core/domain/entities/user_data.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/sign_up/sign_up_cubit.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/sign_up/sign_up_cubit_use_cases.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/external/router_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

final locator = GetIt.I;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockSignUpUseCase mockSignUpUseCase;
  late MockSaveUserDataUseCase mockSaveUserDataUseCase;
  late MockSetSessionUseCase mockSetSessionUseCase;
  late MockNavigationClient mockNavigationClient;
  late SignUpCubit signUpCubit;
  late UserDataEntity userData;

  setUpAll(() {
    userData = UserDataEntity(
      user: User(
        id: faker.guid.guid(),
        firstName: faker.person.firstName(),
        lastName: faker.person.lastName(),
        username: faker.internet.userName(),
        email: faker.internet.email(),
        isActive: true,
      ),
      accessToken: faker.jwt.valid(),
      refreshToken: faker.jwt.valid(),
    );
    registerFallbackValue(const SignUpEntity(name: '', email: '', password: ''));
    registerFallbackValue(const MockPageRouteInfo());
    registerFallbackValue(userData);
  });

  setUp(() {
    mockSignUpUseCase = MockSignUpUseCase();
    mockSetSessionUseCase = MockSetSessionUseCase();
    mockSaveUserDataUseCase = MockSaveUserDataUseCase();
    mockNavigationClient = MockNavigationClient();
    when(() => mockNavigationClient.navigatorKey).thenReturn(GlobalKey<NavigatorState>());

    locator
      ..registerSingleton<SignUpUseCase>(mockSignUpUseCase)
      ..registerSingleton<SaveUserDataUseCase>(mockSaveUserDataUseCase)
      ..registerSingleton<SetSessionUseCase>(mockSetSessionUseCase)
      ..registerSingleton<NavigationClient>(mockNavigationClient);

    final useCases = SignUpCubitUseCases(
      signUp: mockSignUpUseCase,
      saveUserData: mockSaveUserDataUseCase,
      setSession: mockSetSessionUseCase,
    );
    signUpCubit = SignUpCubit(useCases: useCases);
  });

  tearDown(locator.reset);

  blocTest<SignUpCubit, SignUpState>(
    'togglePasswordVisibility should flip passwordVisibility state',
    build: () => signUpCubit,
    act: (cubit) => cubit.togglePasswordVisibility(),
    expect: () => [
      const SignUpState(passwordVisibility: true),
    ],
  );

  blocTest<SignUpCubit, SignUpState>(
    'signUp should handle successful sign up, save data, and navigate',
    build: () {
      when(() => mockSetSessionUseCase.call(userData)).thenAnswer((_) {});
      when(() => mockNavigationClient.replaceAllRoute(any())).thenAnswer((_) async {});
      when(() => mockSignUpUseCase.call(any()))
          .thenAnswer((_) async => SuccessState(data: userData));
      when(() => mockSaveUserDataUseCase.call(any()))
          .thenAnswer((_) async => const SuccessState(data: true));

      return signUpCubit;
    },
    act: (cubit) async {
      await cubit.signUp(
        name: faker.person.name(),
        email: faker.internet.email(),
        password: faker.internet.password(),
      );
    },
    verify: (_) {
      verify(() => mockSignUpUseCase.call(any())).called(1);
      verify(() => mockSetSessionUseCase.call(any())).called(1);
      verify(() => mockSaveUserDataUseCase.call(any())).called(1);
      verify(() => mockNavigationClient.replaceAllRoute(any())).called(1);
    },
  );

  blocTest<SignUpCubit, SignUpState>(
    'signUp should not navigate or save data on failure',
    build: () {
      when(() => mockSignUpUseCase.call(any()))
          .thenAnswer((_) async => const FailureState(message: 'Sign up failed'));

      return signUpCubit;
    },
    act: (cubit) async {
      await cubit.signUp(
        name: faker.person.name(),
        email: faker.internet.email(),
        password: faker.internet.password(),
      );
    },
    verify: (_) {
      verify(() => mockSignUpUseCase.call(any())).called(1);
      verifyNever(() => mockSetSessionUseCase.call(any()));
      verifyNever(() => mockSaveUserDataUseCase.call(any()));
      verifyNever(() => mockNavigationClient.replaceAllRoute(any()));
    },
  );
}
