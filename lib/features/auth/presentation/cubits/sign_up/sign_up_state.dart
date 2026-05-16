part of 'sign_up_cubit.dart';

class SignUpState extends BaseState {
  const SignUpState({
    required this.passwordVisibility,
  });

  const SignUpState.initial() : passwordVisibility = false;

  final bool passwordVisibility;

  @override
  List<Object> get props => [passwordVisibility];
}
