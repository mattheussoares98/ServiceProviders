import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_profile_use_case.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'accept_invite_state.dart';

@LazySingleton()
class AcceptInviteCubitUseCases {
  const AcceptInviteCubitUseCases({
    required this.changePassword,
    required this.updateUserProfile,
    required this.getUserProfileById,
    required this.setSession,
    required this.saveUserData,
    required this.saveSelectedMode,
  });

  final ChangePasswordUseCase changePassword;
  final UpdateUserProfileUseCase updateUserProfile;
  final GetUserProfileByIdUseCase getUserProfileById;
  final SetSessionUseCase setSession;
  final SaveUserDataUseCase saveUserData;
  final SaveSelectedModeUseCase saveSelectedMode;
}

@injectable
class AcceptInviteCubit extends BaseCubit<AcceptInviteState> {
  AcceptInviteCubit({
    required AcceptInviteCubitUseCases useCases,
    required SupabaseAuthClient authClient,
  }) : _useCases = useCases,
       _authClient = authClient,
       super(const AcceptInviteState.empty());

  final AcceptInviteCubitUseCases _useCases;
  final SupabaseAuthClient _authClient;
  StreamSubscription<AuthState>? _authSubscription;

  void initialize() {
    // ── Sync fragment check (must be first, before any await/microtask) ──────
    // The URL fragment is readable synchronously. Supabase only clears it
    // after its own async processing runs. We capture error info here, before
    // it is gone, so we can show a meaningful message instead of a spinner.
    if (kIsWeb) {
      final fragment = Uri.base.fragment;
      if (fragment.contains('error=')) {
        final params = Uri.splitQueryString(fragment);
        final errorCode = params['error_code'] ?? '';
        final errorDescription = Uri.decodeComponent(
          params['error_description'] ?? '',
        ).replaceAll('+', ' ');

        final message = switch (errorCode) {
          'otp_expired' =>
            'Este convite expirou. Solicite um novo convite ao administrador.'
                .hardcoded,
          'access_denied' =>
            'Acesso negado. O convite pode ter expirado ou já foi utilizado.'
                .hardcoded,
          _ =>
            errorDescription.isNotEmpty
                ? errorDescription
                : 'Link de convite inválido.'.hardcoded,
        };

        emit(
          state.copyWith(
            status: StateStatus.loadingError,
            errorMessage: message,
          ),
        );
        return;
      }
    }
    // ─────────────────────────────────────────────────────────────────────────

    final userId = _authClient.currentSession?.user.id;
    if (userId != null) {
      loadProfile(userId);
      return;
    }

    // On web, Supabase processes the invite token from the URL fragment
    // automatically and fires an onAuthStateChange event. By the time
    // any async code runs, the fragment is already cleared from the URL.
    // Instead, always listen to the auth stream and wait for the session.
    //
    // If no session arrives within the timeout, the user most likely navigated
    // to this URL directly (no invite token), so we redirect them to login.
    emit(state.copyWith(status: StateStatus.loading));
    bool sessionReceived = false;

    _authSubscription = _authClient.onAuthStateChange.listen((data) {
      final newUserId = data.session?.user.id;
      if (newUserId != null) {
        sessionReceived = true;
        loadProfile(newUserId);
        _authSubscription?.cancel();
        _authSubscription = null;
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (isClosed || sessionReceived) return;
      _authSubscription?.cancel();
      _authSubscription = null;
      replaceAllRoute(const LoginRoute());
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(passwordVisibility: !state.passwordVisibility));
  }

  void toggleConfirmPasswordVisibility() {
    emit(
      state.copyWith(
        confirmPasswordVisibility: !state.confirmPasswordVisibility,
      ),
    );
  }

  Future<void> loadProfile(String id) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.getUserProfileById.call(id);
    if (isClosed) return;

    if (dataState is SuccessState<UserProfileEntity>) {
      emit(
        state.copyWith(status: StateStatus.loaded, userProfile: dataState.data),
      );
    } else {
      final sessionUser = _authClient.currentSession?.user;
      if (sessionUser != null) {
        final fallbackProfile = UserProfileEntity(
          id: sessionUser.id,
          createdAt: sessionUser.createdAt.toDateTime() ?? DateTime.now(),
          updatedAt: sessionUser.updatedAt?.toDateTime() ?? DateTime.now(),
          companyId: '',
          permissionGroupId: '',
          name:
              (sessionUser.userMetadata?['name'] as String?) ??
              sessionUser.email?.split('@')[0] ??
              '',
          email: sessionUser.email ?? '',
          isActive: false,
          isAdmin: false,
        );
        emit(
          state.copyWith(
            status: StateStatus.loaded,
            userProfile: fallbackProfile,
          ),
        );
      } else {
        showDataStateToast(dataState);
        emit(
          state.copyWith(
            status: StateStatus.loadingError,
            errorMessage: dataState.message,
          ),
        );
      }
    }
  }

  Future<bool> acceptInvite({
    required String name,
    required String password,
  }) async {
    final profile = state.userProfile;
    if (profile == null) {
      showErrorToast('Perfil do usuário não carregado.'.hardcoded);
      return false;
    }

    emit(state.copyWith(status: StateStatus.loading));

    if (profile.isActive) {
      emit(state.copyWith(status: StateStatus.loaded));
      return true;
    }

    // 1. Update the password
    final changePassResult = await _useCases.changePassword.call(password);
    if (isClosed) return false;

    if (changePassResult is! SuccessState) {
      showDataStateToast(changePassResult);
      emit(state.copyWith(status: StateStatus.loaded));
      return false;
    }

    // 2. Update the user profile (name and set active) if company user
    final updatedProfile = profile.copyWith(name: name, isActive: true);

    if (profile.companyId.isNotEmpty) {
      final updateProfileResult =
          await _useCases.updateUserProfile.call(updatedProfile);
      if (isClosed) return false;
      if (updateProfileResult is! SuccessState) {
        showDataStateToast(updateProfileResult);
        emit(state.copyWith(status: StateStatus.loaded));
        return false;
      }
    }

    // 3. Update the session with the new user profile details
    final session = _authClient.currentSession;
    final userData = UserDataEntity(
      user: updatedProfile,
      accessToken: session?.accessToken ?? '',
      refreshToken: session?.refreshToken ?? '',
    );

    _useCases.setSession.call(userData);
    await _useCases.saveUserData.call(userData);

    showSuccessToast('Cadastro concluído com sucesso!'.hardcoded);
    emit(state.copyWith(status: StateStatus.loaded));
    return true;
  }

  Future<void> navigateToHome() async {
    final profile = state.userProfile;
    if (profile != null && profile.companyId.isEmpty) {
      await _useCases.saveSelectedMode.call(AppMode.provider.name);
      await replaceAllRoute(const ProviderHomeRoute());
    } else {
      await replaceAllRoute(const HomeRoute());
    }
  }

  Future<void> navigateToSplash() async {
    await replaceAllRoute(const SplashRoute());
  }
}
