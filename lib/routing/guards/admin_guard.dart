import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/features/auth/domain/repositories/session_repository.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:get_it/get_it.dart';

final class AdminGuard extends AutoRouteGuard {
  const AdminGuard();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final session = GetIt.I<SessionRepository>();
    if (session.isLoggedIn && session.userData.user.isAdmin) {
      return resolver.next();
    }

    router.replaceAll([const CompanyRoute()]);
  }
}
