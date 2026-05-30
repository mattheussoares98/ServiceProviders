import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/routing/guards/authenticated_guard.dart';
import 'package:clean_architecture/routing/helper/route_data.dart';
import 'package:clean_architecture/routing/routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: LoginRoute.page, path: kLoginPath),
    AutoRoute(page: SignUpRoute.page, path: kSignUpPath),
    AutoRoute(page: EmailConfirmationRoute.page, path: kEmailConfirmationPath),
    AutoRoute(page: ChangePasswordRoute.page, path: kChangePasswordPath),
    // AutoRoute(page: HomeRoute.page, path: '/home'),
    AutoRoute(
      path: kHomePath,
      page: HomeRoute.page,
      initial: true,
      guards: const [AuthenticatedGuard()],
      children: const [
        // AutoRoute(path: kHomePath, page: HomeRoute.page, initial: true),
        // AutoRoute(path: kSettingPath, page: SettingRoute.page),
      ],
    ),
  ];
}
