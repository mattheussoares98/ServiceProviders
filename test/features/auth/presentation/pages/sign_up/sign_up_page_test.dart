import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/sign_up/sign_up_cubit.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/sign_up/sign_up_cubit_use_cases.dart';
import 'package:clean_architecture/features/auth/presentation/pages/sign_up/sign_up_page.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:clean_architecture/shared_ui/themes/theme.dart';
import 'package:clean_architecture/shared_ui/utils/screen_util/screen_util.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol/patrol.dart';

import '../../../../../../testing/helpers/test_factory.dart';
import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/external/router_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

final locator = GetIt.I;

class MockScreenObserverCubit extends MockCubit<ScreenObserverState>
    implements ScreenObserverCubit {}

void main() {
  late MockSignUpUseCase mockSignUpUseCase;
  late MockSaveUserDataUseCase mockSaveUserDataUseCase;
  late MockSetSessionUseCase mockSetSessionUseCase;
  late MockNavigationClient mockNavigationClient;
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
    mockSaveUserDataUseCase = MockSaveUserDataUseCase();
    mockSetSessionUseCase = MockSetSessionUseCase();
    mockNavigationClient = MockNavigationClient();

    locator
      ..registerSingleton<SignUpUseCase>(mockSignUpUseCase)
      ..registerSingleton<SaveUserDataUseCase>(mockSaveUserDataUseCase)
      ..registerSingleton<SetSessionUseCase>(mockSetSessionUseCase)
      ..registerSingleton<NavigationClient>(mockNavigationClient)
      ..registerFactory<SignUpCubit>(
        () => SignUpCubit(
          useCases: SignUpCubitUseCases(
            signUp: mockSignUpUseCase,
            saveUserData: mockSaveUserDataUseCase,
            setSession: mockSetSessionUseCase,
          ),
        ),
      );

    const screenDetails = ScreenDetails(
      logicalSize: Size(1920, 1280),
      physicalSize: Size(1920, 1280),
      devicePixelRatio: 1,
    );
    ScreenUtil.I.configureScreen(screenDetails);
  });

  tearDown(locator.reset);

  patrolWidgetTest('successfully signs up a new user and navigates', ($) async {
    // Arrange
    final fakeName = faker.person.name();
    final fakeEmail = faker.internet.email();
    final fakePassword = '${faker.internet.password()}!123';

    when(() => mockSetSessionUseCase.call(userData)).thenAnswer((_) {});
    when(
      () => mockNavigationClient.replaceAllRoute(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSignUpUseCase.call(any()),
    ).thenAnswer((_) async => SuccessState(data: userData));
    when(
      () => mockSaveUserDataUseCase.call(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));

    final mockScreenObserverCubit = MockScreenObserverCubit();
    when(
      () => mockScreenObserverCubit.state,
    ).thenReturn(ScreenObserverState.initial());
    when(
      () => mockScreenObserverCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    await $.tester.binding.setSurfaceSize(const Size(1920, 1280));

    // Render Page
    await $.pumpWidget(
      BlocProvider<ScreenObserverCubit>(
        create: (_) => mockScreenObserverCubit,
        child: MaterialApp(theme: lightTheme, home: const SignUpPage()),
      ),
    );

    await $.pumpAndSettle();

    // Enter SignUp Details
    await $.tester.enterText(find.byType(TextField).at(0), fakeName);
    await $.tester.enterText(find.byType(TextField).at(1), fakeEmail);
    await $.tester.enterText(find.byType(TextField).at(2), fakePassword);
    await $.pumpAndSettle();

    // Tap Confirm button
    await $.tester.tap(find.byType(ElevatedButton));
    await $.pumpAndSettle();

    // Verify sign up flow triggers correct use cases and navigates
    verify(() => mockSignUpUseCase.call(any())).called(1);
    verify(() => mockSetSessionUseCase.call(any())).called(1);
    verify(() => mockSaveUserDataUseCase.call(any())).called(1);
    verify(() => mockNavigationClient.replaceAllRoute(any())).called(1);
  });

  patrolWidgetTest(
    'toggles password visibility when the visibility icon is tapped',
    ($) async {
      // Arrange
      final mockScreenObserverCubit = MockScreenObserverCubit();
      when(
        () => mockScreenObserverCubit.state,
      ).thenReturn(ScreenObserverState.initial());
      when(
        () => mockScreenObserverCubit.stream,
      ).thenAnswer((_) => const Stream.empty());

      await $.tester.binding.setSurfaceSize(const Size(1920, 1280));

      await $.pumpWidget(
        BlocProvider<ScreenObserverCubit>(
          create: (_) => mockScreenObserverCubit,
          child: MaterialApp(theme: lightTheme, home: const SignUpPage()),
        ),
      );

      await $.pumpAndSettle();

      // Find password text field and check initial obscure text state
      final passwordFinder = find.byType(TextField).at(2);
      var passwordField = $.tester.widget<TextField>(passwordFinder);
      expect(passwordField.obscureText, isTrue);

      // Tap password visibility toggle icon (starts as visibility_off)
      await $.tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await $.pumpAndSettle();

      // Verify password text field is no longer obscure
      passwordField = $.tester.widget<TextField>(passwordFinder);
      expect(passwordField.obscureText, isFalse);

      // Tap visibility icon again to obscure it again
      await $.tester.tap(find.byIcon(Icons.visibility_outlined));
      await $.pumpAndSettle();

      // Verify it is obscured again
      passwordField = $.tester.widget<TextField>(passwordFinder);
      expect(passwordField.obscureText, isTrue);
    },
  );

  patrolWidgetTest(
    'displays form validation errors for empty fields and invalid email',
    ($) async {
      // Arrange
      final mockScreenObserverCubit = MockScreenObserverCubit();
      when(
        () => mockScreenObserverCubit.state,
      ).thenReturn(ScreenObserverState.initial());
      when(
        () => mockScreenObserverCubit.stream,
      ).thenAnswer((_) => const Stream.empty());

      await $.tester.binding.setSurfaceSize(const Size(1920, 1280));

      await $.pumpWidget(
        BlocProvider<ScreenObserverCubit>(
          create: (_) => mockScreenObserverCubit,
          child: MaterialApp(theme: lightTheme, home: const SignUpPage()),
        ),
      );

      await $.pumpAndSettle();

      // 1. Submit empty form
      await $.tester.tap(find.byType(ElevatedButton));
      await $.pumpAndSettle();

      // Verify required field errors are shown
      expect(find.text('Username is required.'), findsOneWidget);
      expect(find.text('Email address is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);

      // Verify SignUpUseCase is not called
      verifyNever(() => mockSignUpUseCase.call(any()));

      // 2. Enter invalid email and see invalid email error
      final fakeInvalidEmail = faker.randomGenerator.string(
        10,
      ); // not a valid email
      await $.tester.enterText(
        find.byType(TextField).at(0),
        faker.person.name(),
      );
      await $.tester.enterText(find.byType(TextField).at(1), fakeInvalidEmail);
      await $.tester.enterText(
        find.byType(TextField).at(2),
        faker.internet.password(),
      );
      await $.pumpAndSettle();

      await $.tester.tap(find.byType(ElevatedButton));
      await $.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      verifyNever(() => mockSignUpUseCase.call(any()));
    },
  );
}
