import 'dart:async';

import 'package:clean_architecture/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/update_user_profile_use_case.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:injectable/injectable.dart';
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
  });

  final ChangePasswordUseCase changePassword;
  final UpdateUserProfileUseCase updateUserProfile;
  final GetUserProfileByIdUseCase getUserProfileById;
  final SetSessionUseCase setSession;
  final SaveUserDataUseCase saveUserData;
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
    final userId = _authClient.currentSession?.user.id;
    if (userId != null) {
      loadProfile(userId);
      return;
    }

    if (kIsWeb) {
      final fragment = Uri.base.fragment;
      final hasAuthParams =
          fragment.contains('access_token') || fragment.contains('error');

      if (!hasAuthParams) {
        _authSubscription?.cancel();
        _authSubscription = null;

        Future.microtask(() {
          _useCases.setSession.call(UserDataEntity.empty());
          _useCases.saveUserData.call(UserDataEntity.empty());
          replaceAllRoute(const LoginRoute());
        });
        return;
      }
    }

    emit(state.copyWith(status: StateStatus.loading));
    _authSubscription = _authClient.onAuthStateChange.listen((data) {
      final newUserId = data.session?.user.id;
      if (newUserId != null) {
        loadProfile(newUserId);
        _authSubscription?.cancel();
        _authSubscription = null;
      }
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

    final updateProfileResult = await _useCases.updateUserProfile.call(
      updatedProfile,
    );
    if (isClosed) return false;

    if (updateProfileResult is! SuccessState) {
      showDataStateToast(updateProfileResult);
      emit(state.copyWith(status: StateStatus.loaded));
      return false;
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
}
