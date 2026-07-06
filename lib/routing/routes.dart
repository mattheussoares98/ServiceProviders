import 'package:auto_route/auto_route.dart';
import 'package:o_jogo_da_obra/routing/guards/admin_guard.dart';
import 'package:o_jogo_da_obra/routing/guards/authenticated_guard.dart';
import 'package:o_jogo_da_obra/routing/helper/route_data.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';

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
    AutoRoute(page: AcceptInviteRoute.page, path: kAcceptInvitePath),
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
        AutoRoute(page: CompanyRoute.page, path: kCompanyPath),
        AutoRoute(
          page: CreateCompanyRoute.page,
          path: '$kCompanyPath/$kCreateCompanyPath',
          guards: const [AdminGuard()],
        ),
        AutoRoute(page: ConfigurationsRoute.page, path: kConfigurationsPath),
        AutoRoute(page: UsersAndPermissionsRoute.page, path: kPermissionsPath),
        AutoRoute(
          page: EditGroupPermissionsRoute.page,
          path: '$kPermissionsPath/$kEditGroupPermissionsPath',
        ),
        AutoRoute(
          page: EditUserPermissionsRoute.page,
          path: '$kPermissionsPath/$kEditUserPermissionsPath',
        ),
        AutoRoute(
          page: CreateUpdateAreaRoute.page,
          path: '$kCreateUpdateAreaRoute/$kCreateUpdateAreaPath',
        ),
        AutoRoute(
          page: CreateUpdateLocationRoute.page,
          path: '$kCreateUpdateLocationRoute/$kCreateUpdateLocationPath',
        ),
        AutoRoute(
          page: CreateUpdateAssetRoute.page,
          path: '$kCreateUpdateAssetRoute/$kCreateUpdateAssetPath',
        ),
        AutoRoute(
          page: CreateUpdateWorkOrderRoute.page,
          path: '$kCreateUpdateWorkOrderRoute/$kCreateUpdateWorkOrderPath',
        ),
      ],
    ),
  ];
}
