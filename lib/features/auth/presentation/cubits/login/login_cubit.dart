import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/initializations/notifications_service.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_action.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/create_access_log_request_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/authentication_entity.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/login/login_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'login_state.dart';

enum LoginSections implements SectionKey { resetPassword }

@injectable
class LoginCubit extends BaseCubit<LoginState> {
  LoginCubit({
    required LoginCubitUseCases useCases,
    required LocalStorageClient localStorageClient,
  }) : _useCases = useCases,
       _localStorageClient = localStorageClient,
       super(const LoginState.initial());

  final LoginCubitUseCases _useCases;
  final LocalStorageClient _localStorageClient;

  Future<void> clearSession() async {
    final dataState = await _useCases.getUserData.call();
    if (dataState is SuccessState &&
        dataState.data?.user.id.isNotEmpty == true) {
      await _useCases.logOut.call();
    }
  }

  Future<void> getUserData() async {
    final dataState = await _useCases.getUserData.call();
    if (dataState is SuccessState) {
      emit(state.copyWith(userData: dataState.data));
    }
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(passwordVisibility: !state.passwordVisibility));
  }

  Future<void> login({required String email, required String password}) async {
    emit(
      state.copyWith(
        sections: withSection(BaseSections.load, SectionStatus.running),
      ),
    );

    final authentication = AuthenticationEntity(
      email: email,
      password: password,
    );
    final dataState = await _useCases.login.call(authentication);
    if (isClosed) return;
    showDataStateToast(dataState);

    if (dataState is SuccessState) {
      _useCases.setSession(dataState.data!);
      await _useCases.saveUserData(dataState.data!);
      unawaited(NotificationsService.instance.syncDeviceToken());

      final companyId = _useCases.getActiveCompanyId.call();
      if (companyId.isNotEmpty) {
        unawaited(
          _useCases.createAccessLog.call(
            CreateAccessLogRequestEntity(
              companyId: companyId,
              userId: dataState.data!.user.id,
              action: AccessLogAction.login,
            ),
          ),
        );
      }

      final userId = dataState.data!.user.id;
      final providerProfilesState = await _useCases
          .getServiceProviderProfilesByAuthUser
          .call(userId);

      final hasInternalProfile = dataState.data!.user.companyId.isNotEmpty;
      final hasProviderProfile =
          providerProfilesState is SuccessState &&
          providerProfilesState.data!.isNotEmpty;

      if (hasInternalProfile && hasProviderProfile) {
        final savedMode = _localStorageClient.getSelectedMode();
        if (savedMode == AppMode.internal.name) {
          await replaceAllRoute(const HomeRoute());
        } else if (savedMode == AppMode.provider.name) {
          await replaceAllRoute(const ProviderHomeRoute());
        } else {
          await replaceAllRoute(const ModeSwitcherRoute());
        }
      } else if (hasProviderProfile) {
        await _localStorageClient.saveSelectedMode(AppMode.provider.name);
        await replaceAllRoute(const ProviderHomeRoute());
      } else {
        await _localStorageClient.saveSelectedMode(AppMode.internal.name);
        await replaceAllRoute(const HomeRoute());
      }
    }
    emit(
      state.copyWith(
        sections: withSection(
          BaseSections.load,
          dataState is SuccessState
              ? SectionStatus.success
              : SectionStatus.error,
        ),
      ),
    );
  }

  Future<void> resetPassword(String email) async {
    emit(
      state.copyWith(
        sections: withSection(
          LoginSections.resetPassword,
          SectionStatus.running,
        ),
      ),
    );

    final dataState = await _useCases.resetPassword.call(email);
    if (isClosed) return;
    showDataStateToast(
      dataState,
      message: 'E-mail de recuperação enviado com sucesso!'.hardcoded,
    );

    emit(
      state.copyWith(
        sections: withSection(
          LoginSections.resetPassword,
          dataState is SuccessState
              ? SectionStatus.success
              : SectionStatus.error,
        ),
      ),
    );
    if (dataState is SuccessState) {
      await maybePopRoute();
    }
  }

  Future<void> navigateToSignUp() async {
    await pushRoute(const SignUpRoute());
  }
}
