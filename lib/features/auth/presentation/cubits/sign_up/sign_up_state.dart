part of 'sign_up_cubit.dart';

class SignUpState extends BaseState {
  const SignUpState({
    required this.passwordVisibility,
    required this.confirmPasswordVisibility,
    super.sections,
  });

  const SignUpState.initial()
    : passwordVisibility = false,
      confirmPasswordVisibility = false;

  final bool passwordVisibility;
  final bool confirmPasswordVisibility;

  @override
  List<Object?> get props => [
    passwordVisibility,
    confirmPasswordVisibility,
    sections,
  ];
}
