part of 'login_cubit.dart';

class LoginState extends BaseState {
  const LoginState({
    required this.passwordVisibility,
    this.userData,
    super.sections = const {},
  });

  const LoginState.initial()
    : passwordVisibility = false,
      userData = null,
      super(sections: const {});

  final bool passwordVisibility;
  final UserDataEntity? userData;

  LoginState copyWith({
    bool? passwordVisibility,
    UserDataEntity? userData,
    Map<SectionKey, SectionState>? sections,
  }) => LoginState(
    passwordVisibility: passwordVisibility ?? this.passwordVisibility,
    userData: userData ?? this.userData,
    sections: sections ?? this.sections,
  );

  @override
  List<Object?> get props => [
    passwordVisibility,
    userData,
    sections,
  ];
}
