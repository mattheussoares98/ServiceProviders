import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/splash/splash_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'splash_state.dart';

@injectable
class SplashCubit extends BaseCubit<SplashState> {
  SplashCubit({
    required SplashCubitUseCases useCases,
    required SupabaseAuthClient authClient,
  }) : _useCases = useCases,
       _authClient = authClient,
       super(const SplashState());

  final SplashCubitUseCases _useCases;
  final SupabaseAuthClient _authClient;

  void checkInitialRoute({bool isInviteLink = false}) {
    // 1. If Supabase has an active session (e.g. from an invite/magic link redirect),
    // but local user data is not set up yet -> route to AcceptInviteRoute
    final hasActiveInviteSession =
        _authClient.currentSession != null &&
        _useCases.sessionRepository.userData.user.id.isEmpty;

    if (isInviteLink || hasActiveInviteSession) {
      emit(state.copyWith(target: SplashRouteTarget.acceptInvite));
      return;
    }

    // 2. If fully logged in, route according to user type/mode
    if (_useCases.sessionRepository.isLoggedIn) {
      final mode = _useCases.getSelectedMode.call();
      final user = _useCases.getSessionUser.call();
      if (mode == AppMode.provider.name || user.companyId.isEmpty) {
        emit(state.copyWith(target: SplashRouteTarget.providerHome));
      } else {
        emit(state.copyWith(target: SplashRouteTarget.home));
      }
      return;
    }

    // 3. Otherwise, go to Login
    emit(state.copyWith(target: SplashRouteTarget.login));
  }
}
