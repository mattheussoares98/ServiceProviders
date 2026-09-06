import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/use_cases/create_access_log_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/authentication_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_user_data_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/login_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/login/login_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/login/login_page.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_by_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/keyboard_visibility/keyboard_visibility_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/themes/theme.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';
import 'package:patrol/patrol.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/external/router_mocks.dart';
import '../../../../../../testing/mocks/factories/system_factory.dart';
import '../../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../../testing/mocks/repository_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

final locator = GetIt.I;

class MockScreenObserverCubit extends MockCubit<ScreenObserverState>
    implements ScreenObserverCubit {}

class MockKeyboardVisibilityCubit extends MockCubit<bool>
    implements KeyboardVisibilityCubit {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockLogOutUseCase mockLogOutUseCase;
  late MockSessionRepository mockSessionRepository;
  late MockNavigationClient mockNavigationClient;
  late MockResetPasswordUseCase mockResetPasswordUseCase;
  late MockSetSessionUseCase mockSetSessionUseCase;
  late MockGetUserDataUseCase mockGetUserDataUseCase;
  late MockSaveUserDataUseCase mockSaveUserDataUseCase;
  late UserDataEntity userData;
  late MockGetServiceProviderProfilesByAuthUserUseCase
  getServiceProviderProfilesByAuthUserUseCase;
  late MockLocalStorageClient mockLocalStorageClient;

  setUpAll(() {
    userData = UserFactory.makeUserDataEntity();
    registerFallbackValue(const AuthenticationEntity(email: '', password: ''));
    registerFallbackValue(const MockPageRouteInfo());
    registerFallbackValue(userData);
    registerFallbackValue(SystemFactory.makeCreateAccessLogRequestEntity());
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
    final mockCreateAccessLogUseCase = MockCreateAccessLogUseCase();
    final mockGetActiveCompanyIdUseCase = MockGetActiveCompanyIdUseCase();
    getServiceProviderProfilesByAuthUserUseCase =
        MockGetServiceProviderProfilesByAuthUserUseCase();
    mockLocalStorageClient = MockLocalStorageClient();

    when(
      () => mockCreateAccessLogUseCase.call(any()),
    ).thenAnswer((_) async => SuccessState.nil);
    when(
      mockGetActiveCompanyIdUseCase.call,
    ).thenReturn(userData.user.companyId);

    locator
      ..registerSingleton<LoginUseCase>(mockLoginUseCase)
      ..registerSingleton<LogOutUseCase>(mockLogOutUseCase)
      ..registerSingleton<SessionRepository>(mockSessionRepository)
      ..registerSingleton<NavigationClient>(mockNavigationClient)
      ..registerSingleton<ResetPasswordUseCase>(mockResetPasswordUseCase)
      ..registerSingleton<SetSessionUseCase>(mockSetSessionUseCase)
      ..registerSingleton<GetUserDataUseCase>(mockGetUserDataUseCase)
      ..registerSingleton<SaveUserDataUseCase>(mockSaveUserDataUseCase)
      ..registerSingleton<LocalStorageClient>(mockLocalStorageClient)
      ..registerSingleton<CreateAccessLogUseCase>(mockCreateAccessLogUseCase)
      ..registerSingleton<GetActiveCompanyIdUseCase>(
        mockGetActiveCompanyIdUseCase,
      )
      ..registerSingleton<GetServiceProviderProfilesByAuthUserUseCase>(
        getServiceProviderProfilesByAuthUserUseCase,
      )
      ..registerFactory<LoginCubit>(
        () => LoginCubit(
          useCases: LoginCubitUseCases(
            login: mockLoginUseCase,
            logOut: mockLogOutUseCase,
            resetPassword: mockResetPasswordUseCase,
            setSession: mockSetSessionUseCase,
            getUserData: mockGetUserDataUseCase,
            saveUserData: mockSaveUserDataUseCase,
            getServiceProviderProfilesByAuthUser:
                getServiceProviderProfilesByAuthUserUseCase,
            createAccessLog: mockCreateAccessLogUseCase,
            getActiveCompanyId: mockGetActiveCompanyIdUseCase,
          ),
          localStorageClient: mockLocalStorageClient,
        ),
      );

    when(() => mockLocalStorageClient.getSelectedMode()).thenReturn(null);

    const screenDetails = ScreenDetails(
      logicalSize: Size(1920, 1280),
      physicalSize: Size(1920, 1280),
      devicePixelRatio: 1,
    );
    ScreenUtil.I.configureScreen(screenDetails);
  });

  tearDown(locator.reset);

  patrolWidgetTest('Login and save the user credential', ($) async {
    // Arrange
    when(() => mockLogOutUseCase.call()).thenAnswer((_) async {});
    when(
      () => mockGetUserDataUseCase.call(),
    ).thenAnswer((_) async => SuccessState(data: userData));
    when(() => mockSetSessionUseCase.call(any())).thenReturn(null);
    when(
      () => mockSaveUserDataUseCase.call(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(
      () => mockLoginUseCase.call(any()),
    ).thenAnswer((_) async => SuccessState(data: userData));

    final mockScreenObserverCubit = MockScreenObserverCubit();
    when(
      () => mockScreenObserverCubit.state,
    ).thenReturn(ScreenObserverState.initial());
    when(
      () => mockScreenObserverCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    final mockKeyboardVisibilityCubit = MockKeyboardVisibilityCubit();
    when(() => mockKeyboardVisibilityCubit.state).thenReturn(false);
    when(
      () => mockKeyboardVisibilityCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    // Set the test binding surface size to match our screen configuration
    // This ensures widgets are within the render tree bounds
    await $.tester.binding.setSurfaceSize(const Size(1920, 1280));

    // Render the view
    await $.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ScreenObserverCubit>(
            create: (_) => mockScreenObserverCubit,
          ),
          BlocProvider<KeyboardVisibilityCubit>(
            create: (_) => mockKeyboardVisibilityCubit,
          ),
        ],
        child: MaterialApp(theme: lightTheme, home: const LoginPage()),
      ),
    );

    // Wait for all animations and async operations to complete
    await $.pumpAndSettle();

    // Expect the login button to be enabled initially
    expect($('Login'), findsOne);
    expect($('Senha'), findsOne);
    final enabledButton = $(
      BaseButton,
    ).which<BaseButton>((b) => b.onTap != null);
    expect(enabledButton, findsOneWidget);
    expect($(BaseTextButton), findsNWidgets(1));
    expect($(PlatformIcon), findsOneWidget);

    // Enter email and password using standard Flutter test approach
    // This avoids hit-testability issues with Patrol's enterText in scrollable content
    await $.tester.enterText(find.byType(BaseTextFormField).first, 'username');
    await $.tester.enterText(find.byType(BaseTextFormField).at(1), 'password');
    await $.pumpAndSettle();

    // Use the login cubit's login method in the login_button widget.
    // Tap the login button using standard Flutter test
    await $.tester.tap(find.byType(BaseButton));
    await $.pumpAndSettle();

    verifyNever(() => mockNavigationClient.replaceAllRoute(any()));
  });
}
