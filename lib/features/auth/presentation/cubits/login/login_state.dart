part of 'login_cubit.dart';

class LoginState extends BaseState {
  const LoginState({
    required this.passwordVisibility,
    this.resetPasswordStatus = DataStatus.initial,
    this.userData,
    super.status,
  });

  const LoginState.initial()
    : passwordVisibility = false,
      resetPasswordStatus = DataStatus.initial,
      userData = null;

  final bool passwordVisibility;
  final DataStatus resetPasswordStatus;
  final UserDataEntity? userData;

  LoginState copyWith({
    bool? passwordVisibility,
    DataStatus? resetPasswordStatus,
    UserDataEntity? userData,
    DataStatus? status,
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
