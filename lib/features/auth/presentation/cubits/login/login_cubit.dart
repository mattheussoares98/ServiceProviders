import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit_use_cases.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'login_state.dart';

@injectable
class LoginCubit extends BaseCubit<LoginState> {
  LoginCubit({required LoginCubitUseCases useCases})
    : _useCases = useCases,
      super(const LoginState.initial());

  final LoginCubitUseCases _useCases;
  final bool _passwordVisibility = false;
  final StateStatus _resetPasswordStatus = StateStatus.initial;

  /// Emits a new State
  void _refreshState({
    StateStatus? resetPasswordStatus,
    StateStatus? status,
    bool? passwordVisibility,
  }) {
    final newState = LoginState(
      passwordVisibility: passwordVisibility ?? _passwordVisibility,
      resetPasswordStatus: resetPasswordStatus ?? _resetPasswordStatus,
      status: status ?? state.status,
    );
    emit(newState);
  }

  /// Clear any stale session data when login page loads
  /// This handles cases where the auth interceptor navigated to login
  /// but couldn't clear the in-memory session data
  void clearSession() {
    _useCases.logOut.call();
  }

  void togglePasswordVisibility() {
    _refreshState(passwordVisibility: !_passwordVisibility);
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    _refreshState(status: StateStatus.loading);

    final authentication = AuthenticationEntity(
      username: username,
      password: password,
    );
    final dataState = await _useCases.login.call(authentication);
    if (isClosed) return;
    showDataStateToast(dataState);

    if (dataState is SuccessState) {
      _useCases.setSession(dataState.data!);
      //because it navigates to the home page, doesn't need to emit a new state
      await replaceAllRoute(const HomeRoute());
    }
    _refreshState(status: StateStatus.loaded);
  }

  Future<void> resetPassword(String email) async {
    _refreshState(resetPasswordStatus: StateStatus.loading);

    final dataState = await _useCases.resetPassword.call(email);
    if (isClosed) return;
    showDataStateToast(
      dataState,
      message: 'E-mail de recuperação enviado com sucesso!'.hardcoded,
    );

    _refreshState(resetPasswordStatus: StateStatus.loaded);
    await maybePopRoute();
  }

  Future<void> navigateToSignUp() async {
    await pushRoute(const SignUpRoute());
  }
}
