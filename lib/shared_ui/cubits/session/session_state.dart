part of 'session_cubit.dart';

class SessionState extends BaseState {
  const SessionState({
    required this.user,
    required this.isLoggedIn,
    super.sections,
  });

  SessionState.initial()
    : user = UserProfileEntity.empty(),
      isLoggedIn = false,
      super();

  final UserProfileEntity user;
  final bool isLoggedIn;

  @override
  List<Object?> get props => [user, isLoggedIn, sections];

  SessionState copyWith({
    UserProfileEntity? user,
    bool? isLoggedIn,
    Map<SectionKey, SectionState>? sections,
  }) {
    return SessionState(
      user: user ?? this.user,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      sections: sections ?? this.sections,
    );
  }
}
