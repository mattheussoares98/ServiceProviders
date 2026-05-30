import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
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

  var _currentState = const LoginState(passwordVisibility: false);

  /// Clear any stale session data when login page loads
  /// This handles cases where the auth interceptor navigated to login
  /// but couldn't clear the in-memory session data
  void clearSession() {
    _useCases.logOut.call(
      email: email,
      name: name,
    ); //TODO here is the problem that is not saving the email and name
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

  Future<void> login({
    required String username,
    required String password,
  }) async {
    _currentState = _currentState.copyWith(status: StateStatus.loading);
    emit(_currentState);

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
