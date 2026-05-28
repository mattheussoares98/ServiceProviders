import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/sign_up/sign_up_cubit.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/sign_up/sign_up_cubit_use_cases.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/helpers/test_factory.dart';
import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/external/router_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

final locator = GetIt.I;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockSignUpUseCase mockSignUpUseCase;
  late MockNavigationClient mockNavigationClient;
  late SignUpCubit signUpCubit;
  late UserDataEntity userData;

  setUpAll(() {
    userData = TestFactory.makeUserDataEntity();
    registerFallbackValue(
      const SignUpEntity(name: '', email: '', password: ''),
    );
    registerFallbackValue(const MockPageRouteInfo());
    registerFallbackValue(userData);
  });

  setUp(() {
    mockSignUpUseCase = MockSignUpUseCase();
    mockNavigationClient = MockNavigationClient();
    when(
      () => mockNavigationClient.navigatorKey,
    ).thenReturn(GlobalKey<NavigatorState>());

    locator
      ..registerSingleton<SignUpUseCase>(mockSignUpUseCase)
      ..registerSingleton<NavigationClient>(mockNavigationClient);

    final useCases = SignUpCubitUseCases(signUp: mockSignUpUseCase);
    signUpCubit = SignUpCubit(useCases: useCases);
  });

  tearDown(locator.reset);

  blocTest<SignUpCubit, SignUpState>(
    'togglePasswordVisibility should flip passwordVisibility state',
    build: () => signUpCubit,
    act: (cubit) => cubit.togglePasswordVisibility(),
    expect: () => [const SignUpState(passwordVisibility: true)],
  );

  blocTest<SignUpCubit, SignUpState>(
    'signUp should handle successful sign up, save data, and navigate',
    build: () {
      when(
        () => mockNavigationClient.replaceAllRoute(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockSignUpUseCase.call(any()),
      ).thenAnswer((_) async => SuccessState(data: userData));
      when(
        () => mockNavigationClient.maybePop<dynamic>(),
      ).thenAnswer((_) async => true);
      when(
        () => mockNavigationClient.maybePop<dynamic>(),
      ).thenAnswer((_) async => true);
      when(
        () => mockNavigationClient.maybePop<void>(any()),
      ).thenAnswer((_) async => true);
      when(
        () => mockNavigationClient.maybePop<void>(),
      ).thenAnswer((_) async => true);
      when(
        () => mockNavigationClient.maybePop<Object?>(any()),
      ).thenAnswer((_) async => true);
      when(
        () => mockNavigationClient.maybePop<Object?>(),
      ).thenAnswer((_) async => true);

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
      verify(() => mockNavigationClient.maybePop<Object?>(any())).called(1);
      verifyNever(() => mockNavigationClient.replaceAllRoute(any()));
    },
  );

  blocTest<SignUpCubit, SignUpState>(
    'signUp should not navigate or save data on failure',
    build: () {
      when(
        () => mockSignUpUseCase.call(any()),
      ).thenAnswer((_) async => FailureState(message: 'Sign up failed'));

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
      verifyNever(() => mockNavigationClient.replaceAllRoute(any()));
    },
  );
}
