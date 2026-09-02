part of 'change_password_cubit.dart';

class ChangePasswordState extends BaseState {
  const ChangePasswordState({
    required this.passwordVisibility,
    required this.confirmPasswordVisibility,
    super.sections = const {},
  });

  const ChangePasswordState.initial()
    : passwordVisibility = false,
      confirmPasswordVisibility = false,
      super(sections: const {});

  final bool passwordVisibility;
  final bool confirmPasswordVisibility;

  @override
  List<Object?> get props => [
    passwordVisibility,
    confirmPasswordVisibility,
    sections,
  ];
}
