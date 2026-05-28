import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit_use_cases.dart';
import 'package:clean_architecture/features/home/presentation/pages/home_page/home_page.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:clean_architecture/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:clean_architecture/shared_ui/themes/theme.dart';
import 'package:clean_architecture/shared_ui/utils/screen_util/screen_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol/patrol.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

final locator = GetIt.I;

class MockScreenObserverCubit extends MockCubit<ScreenObserverState>
    implements ScreenObserverCubit {}

void main() {
  late MockLogOutUseCase mockLogOutUseCase;
  late MockNavigationClient mockNavigationClient;

  setUpAll(() {
    registerFallbackValue(const LoginRoute());
  });

  setUp(() {
    mockLogOutUseCase = MockLogOutUseCase();
    mockNavigationClient = MockNavigationClient();

    locator
      ..registerSingleton<NavigationClient>(mockNavigationClient)
      ..registerSingleton<HomeCubitUseCases>(
        HomeCubitUseCases(logOut: mockLogOutUseCase),
      )
      ..registerFactory<HomeCubit>(
        () => HomeCubit(useCases: locator<HomeCubitUseCases>()),
      );

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

    // Render the view
    await $.pumpWidget(
      BlocProvider<ScreenObserverCubit>(
        create: (_) => mockScreenObserverCubit,
        child: MaterialApp(theme: lightTheme, home: const HomePage()),
      ),
    );

    await $.pumpAndSettle();

    // Verify HomePage renders
    expect($('HomePage'), findsOne);

    // Verify Drawer is NOT open initially
    expect($(Drawer), findsNothing);

    // Tap on the Menu icon in AppBar to open the Drawer
    await $.tester.tap(find.byIcon(Icons.menu));
    await $.pumpAndSettle();

    // Verify Drawer is open
    expect($(Drawer), findsOne);
    expect($('Olá, Usuário!'), findsOne);
    expect($('Início'), findsOne);
    expect($('Perfil'), findsOne);
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
