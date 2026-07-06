import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';

final class AuthenticatedGuard extends AutoRouteGuard {
  const AuthenticatedGuard();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (GetIt.I<SessionRepository>().isLoggedIn) {
      return resolver.next();
    }

    router.replaceAll([const LoginRoute()]);
  }
}
