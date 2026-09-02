part of 'accept_invite_cubit.dart';

class AcceptInviteState extends BaseState {
  const AcceptInviteState({
    super.sections,
    this.userProfile,
    this.passwordVisibility = false,
    this.confirmPasswordVisibility = false,
  });

  const AcceptInviteState.empty()
    : userProfile = null,
      passwordVisibility = false,
      confirmPasswordVisibility = false;

  final UserProfileEntity? userProfile;
  final bool passwordVisibility;
  final bool confirmPasswordVisibility;

  AcceptInviteState copyWith({
    UserProfileEntity? userProfile,
    bool? passwordVisibility,
    bool? confirmPasswordVisibility,
    bool? annulUserProfile,
    Map<SectionKey, SectionState>? sections,
  }) {
    return AcceptInviteState(
      userProfile: annulUserProfile == true
          ? null
          : userProfile ?? this.userProfile,
      passwordVisibility: passwordVisibility ?? this.passwordVisibility,
      confirmPasswordVisibility:
          confirmPasswordVisibility ?? this.confirmPasswordVisibility,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    userProfile,
    passwordVisibility,
    confirmPasswordVisibility,
    sections,
  ];
}
