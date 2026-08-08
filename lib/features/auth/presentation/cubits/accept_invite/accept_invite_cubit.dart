import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/watch_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/accept_service_provider_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_by_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_profile_use_case.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'accept_invite_state.dart';

@LazySingleton()
class AcceptInviteCubitUseCases {
  const AcceptInviteCubitUseCases({
    required this.changePassword,
    required this.updateUserProfile,
    required this.getUserProfileById,
    required this.getServiceProviderProfilesByAuthUser,
    required this.updateServiceProviderProfile,
    required this.acceptServiceProviderInvitation,
    required this.saveSelectedMode,
    required this.getAuthUser,
    required this.watchAuthUser,
    required this.logOut,
  });

  final ChangePasswordUseCase changePassword;
  final UpdateUserProfileUseCase updateUserProfile;
  final GetUserProfileByIdUseCase getUserProfileById;
  final GetServiceProviderProfilesByAuthUserUseCase
  getServiceProviderProfilesByAuthUser;
  final UpdateServiceProviderProfileUseCase updateServiceProviderProfile;
  final AcceptServiceProviderInvitationUseCase acceptServiceProviderInvitation;
  final SaveSelectedModeUseCase saveSelectedMode;
  final GetAuthUserUseCase getAuthUser;
  final WatchAuthUserUseCase watchAuthUser;
  final LogOutUseCase logOut;
}

@injectable
class AcceptInviteCubit extends BaseCubit<AcceptInviteState> {
  AcceptInviteCubit({required AcceptInviteCubitUseCases useCases})
    : _useCases = useCases,
      super(const AcceptInviteState.empty());

  final AcceptInviteCubitUseCases _useCases;
  StreamSubscription<String?>? _authSubscription;

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

    final userId = _useCases.getAuthUser.call()?.id;
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

    _authSubscription = _useCases.watchAuthUser.call().listen((newUserId) {
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
      return;
    }

    // Try fetching Service Provider profile
    final spState = await _useCases.getServiceProviderProfilesByAuthUser.call(
      id,
    );
    if (isClosed) return;

    if (spState is SuccessState<List<ServiceProviderProfileEntity>> &&
        (spState.data?.isNotEmpty ?? false)) {
      final sp = spState.data!.first;
      final spProfileAsUser = UserProfileEntity(
        avatarUrl: null,
        deletedAt: null,
        phone: sp.phone,
        id: sp.authUserId ?? id,
        createdAt: sp.createdAt,
        updatedAt: sp.updatedAt,
        companyId: '', // Empty companyId indicates Service Provider
        permissionGroupId: '',
        name: sp.name,
        email: sp.email,
        isActive: sp.isActive,
        isAdmin: false,
      );
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          userProfile: spProfileAsUser,
        ),
      );
      return;
    }

    final authUser = _useCases.getAuthUser.call();
    if (authUser != null) {
      final fallbackProfile = UserProfileEntity(
        avatarUrl: null,
        deletedAt: null,
        phone: null,
        id: authUser.id,
        createdAt: authUser.createdAt,
        updatedAt: authUser.updatedAt,
        companyId: '',
        permissionGroupId: '',
        name: authUser.name,
        email: authUser.email,
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

    // 2. Update the user profile (name and set active)
    final updatedProfile = profile.copyWith(name: name, isActive: true);

    // If companyId is empty, this is a service provider user
    if (profile.companyId.isEmpty) {
      final spProfilesState = await _useCases
          .getServiceProviderProfilesByAuthUser
          .call(profile.id);
      if (isClosed) return false;
      if (spProfilesState is SuccessState<List<ServiceProviderProfileEntity>> &&
          (spProfilesState.data?.isNotEmpty ?? false)) {
        final spProfile = spProfilesState.data!.first.copyWith(
          name: name,
          isActive: true,
        );
        final updateSpResult = await _useCases.updateServiceProviderProfile
            .call(spProfile);
        if (isClosed) return false;
        if (updateSpResult is! SuccessState) {
          showDataStateToast(updateSpResult);
          emit(state.copyWith(status: StateStatus.loaded));
          return false;
        }
      }
    } else {
      final updateProfileResult = await _useCases.updateUserProfile.call(
        updatedProfile,
      );
      if (isClosed) return false;
      if (updateProfileResult is! SuccessState) {
        showDataStateToast(updateProfileResult);
        emit(state.copyWith(status: StateStatus.loaded));
        return false;
      }
    }

    // 3. Mark the invitation as accepted
    await _useCases.acceptServiceProviderInvitation.call(profile.email);

    // 4. Sign out the temporary invite session and navigate to login.
    //    The invite link creates a one-time Supabase session that must NOT
    //    be persisted. We call logOut use case here so there is no stale
    //    session left — the splash cubit will correctly route to login,
    //    forcing the user to log in with the password they just set.
    showSuccessToast('Cadastro concluído com sucesso!'.hardcoded);
    emit(state.copyWith(status: StateStatus.loaded));
    await _useCases.logOut.call();
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

  // Navigate to login — used after a successful invite acceptance
  // (the invite session has been signed out, the user must log in fresh).
  Future<void> navigateToLogin() async {
    await replaceAllRoute(const LoginRoute());
  }

  Future<void> navigateToSplash() async {
    await replaceAllRoute(const SplashRoute());
  }
}
