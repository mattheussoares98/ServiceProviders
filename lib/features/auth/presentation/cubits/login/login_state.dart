part of 'login_cubit.dart';

class LoginState extends BaseState {
  const LoginState({
    required this.passwordVisibility,
    this.resetPasswordStatus = StateStatus.initial,
    super.status,
  });

  const LoginState.initial()
      : passwordVisibility = false,
        resetPasswordStatus = StateStatus.initial;

  final bool passwordVisibility;
  final StateStatus resetPasswordStatus;

  @override
  List<Object?> get props => [passwordVisibility, resetPasswordStatus, status];
}
