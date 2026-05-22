part of 'login_cubit.dart';

class LoginState extends BaseState {
  const LoginState({required this.passwordVisibility, super.status});

  const LoginState.initial() : passwordVisibility = false;
  final bool passwordVisibility;

  @override
  List<Object?> get props => [passwordVisibility, status];
}
