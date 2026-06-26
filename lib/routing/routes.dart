import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/routing/guards/admin_guard.dart';
import 'package:clean_architecture/routing/guards/authenticated_guard.dart';
import 'package:clean_architecture/routing/helper/route_data.dart';
import 'package:clean_architecture/routing/routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: SplashRoute.page, path: kSplashPath, initial: true),
    AutoRoute(page: LoginRoute.page, path: kLoginPath),
    AutoRoute(page: SignUpRoute.page, path: kSignUpPath),
    AutoRoute(page: EmailConfirmationRoute.page, path: kEmailConfirmationPath),
    AutoRoute(page: ChangePasswordRoute.page, path: kChangePasswordPath),
    AutoRoute(
      path: kHomePath,
      page: HomeRoute.page,
      guards: const [AuthenticatedGuard()],
      children: [
        AutoRoute(
          path: '',
          page: HomeTabsRoute.page,
          children: [
            AutoRoute(page: DashboardRoute.page, path: kDashboardSubPath),
            AutoRoute(page: WorkOrdersRoute.page, path: kWorkOrdersPath),
            AutoRoute(page: AssetsRoute.page, path: kAssetsPath),
            AutoRoute(page: LocationsRoute.page, path: kLocationsPath),
          ],
        ),
        AutoRoute(
          page: CompanyRoute.page,
          path: kCompanyPath,
        ),
        AutoRoute(
          page: CreateCompanyRoute.page,
          path: '$kCompanyPath/$kCreateCompanyPath',
          guards: const [AdminGuard()],
        ),
        AutoRoute(
          page: ConfigurationsRoute.page,
          path: kConfigurationsPath,
        ),
      ],
    ),
  ];
}
