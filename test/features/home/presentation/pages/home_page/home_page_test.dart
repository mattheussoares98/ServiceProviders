import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/themes/theme.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';
import 'package:patrol/patrol.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/repository_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

final locator = GetIt.I;

class MockScreenObserverCubit extends MockCubit<ScreenObserverState>
    implements ScreenObserverCubit {}

class MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

void main() {
  late MockLogOutUseCase mockLogOutUseCase;
  late MockNavigationClient mockNavigationClient;
  late MockSessionRepository mockSessionRepository;
  late MockDashboardCubit mockDashboardCubit;

  setUpAll(() {
    registerFallbackValue(const LoginRoute());
  });

  setUp(() {
    mockLogOutUseCase = MockLogOutUseCase();
    mockNavigationClient = MockNavigationClient();
    mockSessionRepository = MockSessionRepository();
    mockDashboardCubit = MockDashboardCubit();

    when(() => mockSessionRepository.isLoggedIn).thenReturn(true);
    when(
      () => mockDashboardCubit.state,
    ).thenReturn(const DashboardState.initial());
    when(
      () => mockDashboardCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockDashboardCubit.loadDashboardData()).thenAnswer((_) async {});

    locator
      ..registerSingleton<NavigationClient>(mockNavigationClient)
      ..registerSingleton<SessionRepository>(mockSessionRepository)
      ..registerSingleton<HomeCubitUseCases>(
        HomeCubitUseCases(logOut: mockLogOutUseCase),
      )
      ..registerFactory<HomeCubit>(
        () => HomeCubit(useCases: locator<HomeCubitUseCases>()),
      )
      ..registerFactory<DashboardCubit>(() => mockDashboardCubit);

    const screenDetails = ScreenDetails(
      logicalSize: Size(1920, 1280),
      physicalSize: Size(1920, 1280),
      devicePixelRatio: 1,
    );
    ScreenUtil.I.configureScreen(screenDetails);
  });

  tearDown(locator.reset);

  patrolWidgetTest('HomePage opens drawer and triggers logout successfully', (
    $,
  ) async {
    // Arrange
    when(() => mockLogOutUseCase.call()).thenAnswer((_) async {});

    final mockScreenObserverCubit = MockScreenObserverCubit();
    when(
      () => mockScreenObserverCubit.state,
    ).thenReturn(ScreenObserverState.initial());
    when(
      () => mockScreenObserverCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    await $.tester.binding.setSurfaceSize(const Size(1920, 1280));

    final appRouter = AppRouter();

    // Render the view using MaterialApp.router to support AutoTabsScaffold context lookup
    await $.pumpWidget(
      BlocProvider<ScreenObserverCubit>(
        create: (_) => mockScreenObserverCubit,
        child: MaterialApp.router(
          theme: lightTheme,
          routerDelegate: appRouter.delegate(),
          routeInformationParser: appRouter.defaultRouteParser(),
        ),
      ),
    );

    await $.pumpAndSettle();

    // Verify HomePage renders through active tab (DashboardPage with title 'Painel')
    expect($('Painel'), findsOne);

    // Verify Drawer is NOT open initially
    expect($(Drawer), findsNothing);

    // Tap on the Menu icon in AppBar of the active tab to open the Drawer
    await $.tester.tap(find.byIcon(Icons.menu));
    await $.pumpAndSettle();

    // Verify Drawer is open
    expect($(Drawer), findsOne);
    expect($('Olá, Usuário!'), findsOne);
    expect($(Drawer).$('Início'), findsOne);
    expect($('Perfil'), findsOne);
    expect($('Permissões'), findsOne);
    expect($('Configurações'), findsOne);
    expect($('Sair'), findsOne);

    // Tap Logout button inside Drawer
    await $.tester.tap(find.text('Sair'));
    await $.pumpAndSettle();

    // Assert
    verify(() => mockLogOutUseCase.call()).called(1);
    verify(
      () => mockNavigationClient.replaceAllRoute(const LoginRoute()),
    ).called(1);
  });
}
