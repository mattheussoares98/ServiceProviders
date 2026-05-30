part of 'login_cubit.dart';

class LoginState extends BaseState {
  const LoginState({
    required this.passwordVisibility,
    this.resetPasswordStatus = StateStatus.initial,
    this.userData,
    super.status,
  });

  const LoginState.initial()
    : passwordVisibility = false,
      resetPasswordStatus = StateStatus.initial,
      userData = null;

  final bool passwordVisibility;
  final StateStatus resetPasswordStatus;
  final UserDataEntity? userData;

  LoginState copyWith({
    bool? passwordVisibility,
    StateStatus? resetPasswordStatus,
    UserDataEntity? userData,
    StateStatus? status,
  }) => LoginState(
    passwordVisibility: passwordVisibility ?? this.passwordVisibility,
    resetPasswordStatus: resetPasswordStatus ?? this.resetPasswordStatus,
    userData: userData ?? this.userData,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [
    passwordVisibility,
    resetPasswordStatus,
    userData,
    status,
  ];
}
