import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/authentication_entity.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/login/login_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'login_state.dart';

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

  var _currentState = const LoginState(passwordVisibility: false);

  /// Clear any stale session data when login page loads
  /// This handles cases where the auth interceptor navigated to login
  /// but couldn't clear the in-memory session data
  Future<void> clearSession() async {
    final dataState = await _useCases.getUserData.call();
    if (dataState is SuccessState) {
      await _useCases.logOut.call();
    }
  }

  Future<void> getUserData() async {
    final dataState = await _useCases.getUserData.call();
    if (dataState is SuccessState) {
      _currentState = _currentState.copyWith(userData: dataState.data);
      emit(_currentState);
    }
  }

  void togglePasswordVisibility() {
    _currentState = _currentState.copyWith(
      passwordVisibility: !_currentState.passwordVisibility,
    );
    emit(_currentState);
  }

  Future<void> login({required String email, required String password}) async {
    _currentState = _currentState.copyWith(status: StateStatus.loading);
    emit(_currentState);

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
        await replaceAllRoute(const ProviderHomeRoute());
      } else {
        await replaceAllRoute(const HomeRoute());
      }
    }
    _currentState = _currentState.copyWith(status: StateStatus.loaded);
    emit(_currentState);
  }

  Future<void> resetPassword(String email) async {
    _currentState = _currentState.copyWith(
      resetPasswordStatus: StateStatus.loading,
    );
    emit(_currentState);

    final dataState = await _useCases.resetPassword.call(email);
    if (isClosed) return;
    showDataStateToast(
      dataState,
      message: 'E-mail de recuperação enviado com sucesso!'.hardcoded,
    );

    _currentState = _currentState.copyWith(
      resetPasswordStatus: StateStatus.loaded,
    );
    emit(_currentState);
    await maybePopRoute();
  }

  Future<void> navigateToSignUp() async {
    await pushRoute(const SignUpRoute());
  }
}
