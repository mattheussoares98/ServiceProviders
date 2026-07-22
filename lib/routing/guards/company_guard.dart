import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';

final class CompanyGuard extends AutoRouteGuard {
  const CompanyGuard();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final session = GetIt.I<SessionRepository>();
    final localStorage = GetIt.I<LocalStorageClient>();

    if (!session.isLoggedIn) {
      return resolver.next();
    }

    final appMode = AppMode.fromName(localStorage.getSelectedMode());
    if (appMode == AppMode.provider) {
      return resolver.next();
    }

    if (session.userData.user.companyId.isNotEmpty) {
      return resolver.next();
    }

    router.replaceAll([const LoginRoute()]);
  }
}
