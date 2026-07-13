import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/clear_local_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
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

class MockClearLocalAttachmentsUseCase extends Mock
    implements ClearLocalAttachmentsUseCase {}

class MockUsersCubit extends MockCubit<UsersState> implements UsersCubit {}

class MockCompanyCubit extends MockCubit<CompanyState>
    implements CompanyCubit {}

class MockLocationsCubit extends MockCubit<LocationsState>
    implements LocationsCubit {}

class MockAssetsCubit extends MockCubit<AssetsState> implements AssetsCubit {}

class MockWorkOrdersCubit extends MockCubit<WorkOrdersState>
    implements WorkOrdersCubit {}

class MockCategoriesCubit extends MockCubit<CategoriesState>
    implements CategoriesCubit {}

void main() {
  late MockLogOutUseCase mockLogOutUseCase;
  late MockClearLocalAttachmentsUseCase mockClearLocalAttachmentsUseCase;
  late MockNavigationClient mockNavigationClient;
  late MockSessionRepository mockSessionRepository;
  late MockDashboardCubit mockDashboardCubit;
  late MockUsersCubit mockUsersCubit;
  late MockCompanyCubit mockCompanyCubit;
  late MockLocationsCubit mockLocationsCubit;
  late MockAssetsCubit mockAssetsCubit;
  late MockWorkOrdersCubit mockWorkOrdersCubit;
  late MockCategoriesCubit mockCategoriesCubit;

  setUpAll(() {
    registerFallbackValue(const LoginRoute());
  });

  setUp(() {
    mockLogOutUseCase = MockLogOutUseCase();
    mockClearLocalAttachmentsUseCase = MockClearLocalAttachmentsUseCase();
    mockNavigationClient = MockNavigationClient();
    mockSessionRepository = MockSessionRepository();
    mockDashboardCubit = MockDashboardCubit();
    mockUsersCubit = MockUsersCubit();
    mockCompanyCubit = MockCompanyCubit();
    mockLocationsCubit = MockLocationsCubit();
    mockAssetsCubit = MockAssetsCubit();
    mockWorkOrdersCubit = MockWorkOrdersCubit();
    mockCategoriesCubit = MockCategoriesCubit();

    when(() => mockSessionRepository.isLoggedIn).thenReturn(true);
    when(
      () => mockDashboardCubit.state,
    ).thenReturn(const DashboardState.initial());
    when(
      () => mockDashboardCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockDashboardCubit.loadDashboardData()).thenAnswer((_) async {});
    when(
      () => mockClearLocalAttachmentsUseCase(),
    ).thenAnswer((_) async => SuccessState.nil);

    when(() => mockUsersCubit.state).thenReturn(
      const UsersState(
        users: [],
        permissionGroups: [],
        status: StateStatus.loaded,
      ),
    );
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());

    when(
      () => mockCompanyCubit.state,
    ).thenReturn(const CompanyState(status: StateStatus.loaded));
    when(() => mockCompanyCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCompanyCubit.loadCompany()).thenAnswer((_) async {});

    when(() => mockLocationsCubit.state).thenReturn(
      const LocationsState.initial().copyWith(status: StateStatus.loaded),
    );
    when(
      () => mockLocationsCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockLocationsCubit.loadLocationsAndAreas(),
    ).thenAnswer((_) async {});

    when(() => mockAssetsCubit.state).thenReturn(
      const AssetsState.initial().copyWith(status: StateStatus.loaded),
    );
    when(() => mockAssetsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAssetsCubit.loadAssets()).thenAnswer((_) async {});

    when(() => mockWorkOrdersCubit.state).thenReturn(
      const WorkOrdersState.initial().copyWith(status: StateStatus.loaded),
    );
    when(
      () => mockWorkOrdersCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockWorkOrdersCubit.loadWorkOrdersAndChangeRequests(),
    ).thenAnswer((_) async {});

    when(() => mockCategoriesCubit.state).thenReturn(
      const CategoriesState.initial().copyWith(status: StateStatus.loaded),
    );
    when(
      () => mockCategoriesCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockCategoriesCubit.loadCategories()).thenAnswer((_) async {});

    locator
      ..registerSingleton<NavigationClient>(mockNavigationClient)
      ..registerSingleton<SessionRepository>(mockSessionRepository)
      ..registerSingleton<HomeCubitUseCases>(
        HomeCubitUseCases(
          logOut: mockLogOutUseCase,
          clearLocalAttachments: mockClearLocalAttachmentsUseCase,
        ),
      )
      ..registerFactory<HomeCubit>(
        () => HomeCubit(useCases: locator<HomeCubitUseCases>()),
      )
      ..registerFactory<DashboardCubit>(() => mockDashboardCubit)
      ..registerFactory<CompanyCubit>(() => mockCompanyCubit)
      ..registerFactory<LocationsCubit>(() => mockLocationsCubit)
      ..registerFactory<AssetsCubit>(() => mockAssetsCubit)
      ..registerFactory<WorkOrdersCubit>(() => mockWorkOrdersCubit)
      ..registerFactory<CategoriesCubit>(() => mockCategoriesCubit)
      ..registerFactory<UsersCubit>(() => mockUsersCubit);

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
      MultiBlocProvider(
        providers: [
          BlocProvider<ScreenObserverCubit>(
            create: (_) => mockScreenObserverCubit,
          ),
          BlocProvider<UsersCubit>(create: (_) => mockUsersCubit),
        ],
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
    //TODO fix this test
    // Verify Drawer is open
    expect($(Drawer), findsOne);
    expect($('Olá, Usuário!'), findsOne);
    expect($(Drawer).$('Início'), findsOne);
    // expect($('Perfil'), findsOne);
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
