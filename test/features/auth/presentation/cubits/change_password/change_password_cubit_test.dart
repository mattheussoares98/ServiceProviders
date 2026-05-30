import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/change_password/change_password_cubit.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/change_password/change_password_cubit_use_cases.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/external/router_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

final locator = GetIt.I;

void main() {
  late MockChangePasswordUseCase mockChangePasswordUseCase;
  late MockNavigationClient mockNavigationClient;
  late ChangePasswordCubit changePasswordCubit;

  setUpAll(() {
    registerFallbackValue(const MockPageRouteInfo());
  });

  setUp(() {
    mockChangePasswordUseCase = MockChangePasswordUseCase();
    mockNavigationClient = MockNavigationClient();

    locator
      ..registerSingleton<ChangePasswordUseCase>(mockChangePasswordUseCase)
      ..registerSingleton<NavigationClient>(mockNavigationClient);

    final useCases = ChangePasswordCubitUseCases(
      changePassword: mockChangePasswordUseCase,
    );
    changePasswordCubit = ChangePasswordCubit(useCases: useCases);
  });

  tearDown(locator.reset);

  blocTest<ChangePasswordCubit, ChangePasswordState>(
    'togglePasswordVisibility should flip passwordVisibility state',
    build: () => changePasswordCubit,
    act: (cubit) => cubit.togglePasswordVisibility(),
    expect: () => [
      const ChangePasswordState(
        passwordVisibility: true,
        confirmPasswordVisibility: false,
        status: StateStatus.loaded,
      ),
    ],
  );

  blocTest<ChangePasswordCubit, ChangePasswordState>(
    'toggleConfirmPasswordVisibility should flip confirmPasswordVisibility state',
    build: () => changePasswordCubit,
    act: (cubit) => cubit.toggleConfirmPasswordVisibility(),
    expect: () => [
      const ChangePasswordState(
        passwordVisibility: false,
        confirmPasswordVisibility: true,
        status: StateStatus.loaded,
      ),
    ],
  );

  blocTest<ChangePasswordCubit, ChangePasswordState>(
    'changePassword should call changePassword use case and navigate on success',
    build: () {
      when(
        () => mockChangePasswordUseCase.call(any()),
      ).thenAnswer((_) async => SuccessState.nil);
      return changePasswordCubit;
    },
    act: (cubit) async {
      await cubit.changePassword(faker.internet.password());
    },
    expect: () => [
      isA<ChangePasswordState>().having(
        (s) => s.status,
        'status',
        StateStatus.loading,
      ),
      isA<ChangePasswordState>().having(
        (s) => s.status,
        'status',
        StateStatus.loaded,
      ),
    ],
    verify: (_) {
      verify(() => mockChangePasswordUseCase.call(any())).called(1);
      verify(() => mockNavigationClient.replaceAllRoute(any())).called(1);
    },
  );

  blocTest<ChangePasswordCubit, ChangePasswordState>(
    'changePassword should not navigate and emit error state on failure',
    build: () {
      when(() => mockChangePasswordUseCase.call(any())).thenAnswer(
        (_) async => FailureState(message: 'Password update failed'),
      );
      return changePasswordCubit;
    },
    act: (cubit) async {
      await cubit.changePassword(faker.internet.password());
    },
    expect: () => [
      isA<ChangePasswordState>().having(
        (s) => s.status,
        'status',
        StateStatus.loading,
      ),
      isA<ChangePasswordState>().having(
        (s) => s.status,
        'status',
        StateStatus.error,
      ),
    ],
    verify: (_) {
      verify(() => mockChangePasswordUseCase.call(any())).called(1);
      verifyNever(() => mockNavigationClient.replaceAllRoute(any()));
    },
  );
}
