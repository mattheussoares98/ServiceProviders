part of 'accept_invite_cubit.dart';

class AcceptInviteState extends BaseState {
  const AcceptInviteState({
    required super.status,
    this.userProfile,
    super.errorMessage,
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
    StateStatus? status,
    UserProfileEntity? userProfile,
    String? errorMessage,
    bool? passwordVisibility,
    bool? confirmPasswordVisibility,
    bool? annulUserProfile,
  }) {
    return AcceptInviteState(
      status: status ?? this.status,
      userProfile: annulUserProfile == true
          ? null
          : userProfile ?? this.userProfile,
      errorMessage: errorMessage ?? this.errorMessage,
      passwordVisibility: passwordVisibility ?? this.passwordVisibility,
      confirmPasswordVisibility:
          confirmPasswordVisibility ?? this.confirmPasswordVisibility,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userProfile,
    errorMessage,
    passwordVisibility,
    confirmPasswordVisibility,
  ];
}
