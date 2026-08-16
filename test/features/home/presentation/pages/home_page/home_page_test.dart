import 'package:auto_route/auto_route.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/clear_local_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/splash/splash_cubit.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/logout_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/permissions_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/settings_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/user_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/home_drawer_header.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/sla_policies/presentation/cubits/sla_policies/sla_policies_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_sub_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/themes/theme.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';
import 'package:patrol/patrol.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/repository_mocks.dart';

final locator = GetIt.I;

class MockSplashCubit extends MockCubit<SplashState> implements SplashCubit {}

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

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockModeSwitcherCubit extends MockCubit<ModeSwitcherState>
    implements ModeSwitcherCubit {}

class MockSectorsCubit extends MockCubit<SectorsState>
    implements SectorsCubit {}

class MockSlaPoliciesCubit extends MockCubit<SlaPoliciesState>
    implements SlaPoliciesCubit {}

class MockServiceProvidersCubit extends MockCubit<ServiceProvidersState>
    implements ServiceProvidersCubit {}

class MockLocalStorageClient extends Mock implements LocalStorageClient {}

class MockPauseWorkflowCubit extends MockCubit<PauseWorkflowState>
    implements PauseWorkflowCubit {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockNavigationClient mockNavigationClient;
  late MockSessionRepository mockSessionRepository;
  late MockDashboardCubit mockDashboardCubit;
  late MockUsersCubit mockUsersCubit;
  late MockCompanyCubit mockCompanyCubit;
  late MockLocationsCubit mockLocationsCubit;
  late MockAssetsCubit mockAssetsCubit;
  late MockWorkOrdersCubit mockWorkOrdersCubit;
  late MockCategoriesCubit mockCategoriesCubit;
  late MockSessionCubit mockSessionCubit;

  late UserProfileEntity userProfile;

  setUpAll(() {
    registerFallbackValue(const LoginRoute());
    for (final resource in ResourceType.values) {
      for (final action in PermissionAction.values) {
        registerFallbackValue(
          ActionPermission.resource(
            resourceType: resource,
            permissionAction: action,
          ),
        );
      }
    }
    for (final subAction in WorkOrderSubAction.values) {
      registerFallbackValue(ActionPermission.workOrderSubAction(subAction));
    }
  });

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    mockNavigationClient = MockNavigationClient();
    mockSessionRepository = MockSessionRepository();
    mockDashboardCubit = MockDashboardCubit();
    mockUsersCubit = MockUsersCubit();
    mockCompanyCubit = MockCompanyCubit();
    mockLocationsCubit = MockLocationsCubit();
    mockAssetsCubit = MockAssetsCubit();
    mockWorkOrdersCubit = MockWorkOrdersCubit();
    mockCategoriesCubit = MockCategoriesCubit();
    mockSessionCubit = MockSessionCubit();

    userProfile = EntityFactory.makeUserProfileEntity().copyWith(
      annulAvatarUrl: true,
    );

    final mockLocalStorageClient = MockLocalStorageClient();
    when(
      mockLocalStorageClient.getSelectedMode,
    ).thenReturn(AppMode.internal.name);

    when(() => mockSessionRepository.isLoggedIn).thenReturn(true);
    when(() => mockSessionRepository.userData).thenReturn(
      EntityFactory.makeUserDataEntity().copyWith(user: userProfile),
    );
    when(() => mockDashboardCubit.state).thenReturn(
      const DashboardState.initial().copyWith(status: StateStatus.loaded),
    );
    when(
      () => mockDashboardCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockDashboardCubit.loadDashboardData()).thenAnswer((_) async {});
    when(() => mockHomeCubit.state).thenReturn(const HomeState.empty());
    when(() => mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHomeCubit.logout()).thenAnswer((_) async {});

    when(() => mockUsersCubit.state).thenReturn(
      UsersState(
        users: [userProfile],
        permissionGroups: const [],
        status: StateStatus.loaded,
      ),
    );
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.loadAll()).thenAnswer((_) async {});
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);

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

    when(
      () => mockSessionCubit.state,
    ).thenReturn(SessionState(user: userProfile, isLoggedIn: true));
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());

    final mockSplashCubit = MockSplashCubit();
    when(
      () => mockSplashCubit.state,
    ).thenReturn(const SplashState(target: SplashRouteTarget.home));
    when(() => mockSplashCubit.stream).thenAnswer(
      (_) => Stream.value(const SplashState(target: SplashRouteTarget.home)),
    );

    final mockModeSwitcherCubit = MockModeSwitcherCubit();
    when(
      () => mockModeSwitcherCubit.state,
    ).thenReturn(const ModeSwitcherState());
    when(
      () => mockModeSwitcherCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      mockModeSwitcherCubit.checkEligibilityAndLoadMode,
    ).thenAnswer((_) async {});

    final mockSectorsCubit = MockSectorsCubit();
    when(() => mockSectorsCubit.state).thenReturn(const SectorsState.initial());
    when(() => mockSectorsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockSectorsCubit.loadSectors).thenAnswer((_) async {});

    final mockSlaPoliciesCubit = MockSlaPoliciesCubit();
    when(
      () => mockSlaPoliciesCubit.state,
    ).thenReturn(const SlaPoliciesState.initial());
    when(
      () => mockSlaPoliciesCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(mockSlaPoliciesCubit.loadSlaPolicies).thenAnswer((_) async {});

    final mockServiceProvidersCubit = MockServiceProvidersCubit();
    when(
      () => mockServiceProvidersCubit.state,
    ).thenReturn(const ServiceProvidersState.initial());
    when(
      () => mockServiceProvidersCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      mockServiceProvidersCubit.loadCompaniesAndProfiles,
    ).thenAnswer((_) async {});

    final mockPauseWorkflowCubit = MockPauseWorkflowCubit();
    when(
      () => mockPauseWorkflowCubit.state,
    ).thenReturn(const PauseWorkflowState.initial());
    when(
      () => mockPauseWorkflowCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(mockPauseWorkflowCubit.loadPauseReasons).thenAnswer((_) async {});

    locator
      ..registerSingleton<NavigationClient>(mockNavigationClient)
      ..registerSingleton<SessionRepository>(mockSessionRepository)
      ..registerSingleton<LocalStorageClient>(mockLocalStorageClient)
      ..registerFactory<HomeCubit>(() => mockHomeCubit)
      ..registerFactory<DashboardCubit>(() => mockDashboardCubit)
      ..registerFactory<CompanyCubit>(() => mockCompanyCubit)
      ..registerFactory<LocationsCubit>(() => mockLocationsCubit)
      ..registerFactory<AssetsCubit>(() => mockAssetsCubit)
      ..registerFactory<WorkOrdersCubit>(() => mockWorkOrdersCubit)
      ..registerFactory<CategoriesCubit>(() => mockCategoriesCubit)
      ..registerFactory<UsersCubit>(() => mockUsersCubit)
      ..registerFactory<SessionCubit>(() => mockSessionCubit)
      ..registerFactory<SplashCubit>(() => mockSplashCubit)
      ..registerFactory<ModeSwitcherCubit>(() => mockModeSwitcherCubit)
      ..registerFactory<SectorsCubit>(() => mockSectorsCubit)
      ..registerFactory<SlaPoliciesCubit>(() => mockSlaPoliciesCubit)
      ..registerFactory<ServiceProvidersCubit>(() => mockServiceProvidersCubit)
      ..registerFactory<PauseWorkflowCubit>(() => mockPauseWorkflowCubit);

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
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
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
            BlocProvider<SessionCubit>(create: (_) => mockSessionCubit),
          ],
          child: MaterialApp.router(
            theme: lightTheme,
            routerConfig: appRouter.config(
              deepLinkBuilder: (_) => const DeepLink.path('/home'),
            ),
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
      expect($(userProfile.email), findsOne);
      expect($(HomeDrawerHeader), findsOne);
      expect($(UserDrawerItem), findsOne);
      expect($(PermissionsDrawerItem), findsOne);
      expect($(SettingsDrawerItem), findsOne);
      expect($(LogoutDrawerItem), findsOne);

      // Tap Logout button inside Drawer
      await $(LogoutDrawerItem).tap();
      await $.pumpAndSettle();

      expect(find.text('Sim'), findsOneWidget);

      await $.tester.tap(find.text('Sim'));
      await $.pumpAndSettle();

      // Assert
      verify(() => mockHomeCubit.logout()).called(1);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
