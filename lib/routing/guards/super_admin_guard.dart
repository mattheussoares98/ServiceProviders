import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';

final class SuperAdminGuard extends AutoRouteGuard {
  const SuperAdminGuard();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final session = GetIt.I<SessionRepository>();
    if (session.isLoggedIn && session.userData.user.isSuperAdmin) {
      return resolver.next();
    }

    router.replaceAll([const CompanyRoute()]);
  }
}
