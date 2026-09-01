part of 'session_cubit.dart';

class SessionState extends BaseState {
  const SessionState({
    required this.user,
    required this.isLoggedIn,
    super.status,
  });

  SessionState.initial()
    : user = UserProfileEntity.empty(),
      isLoggedIn = false,
      super(status: DataStatus.initial);

  final UserProfileEntity user;
  final bool isLoggedIn;

  @override
  List<Object?> get props => [user, isLoggedIn, status];

  SessionState copyWith({
    UserProfileEntity? user,
    bool? isLoggedIn,
    DataStatus? status,
  }) {
    return SessionState(
      user: user ?? this.user,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      status: status ?? this.status,
    );
  }
}
