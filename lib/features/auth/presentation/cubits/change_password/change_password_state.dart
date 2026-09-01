part of 'change_password_cubit.dart';

class ChangePasswordState extends BaseState {
  const ChangePasswordState({
    required this.passwordVisibility,
    required this.confirmPasswordVisibility,
    super.status,
  });

  const ChangePasswordState.initial()
    : passwordVisibility = false,
      confirmPasswordVisibility = false,
      super(status: DataStatus.initial);

  final bool passwordVisibility;
  final bool confirmPasswordVisibility;

  @override
  List<Object?> get props => [
    passwordVisibility,
    confirmPasswordVisibility,
    status,
  ];
}
