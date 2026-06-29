part of 'invite_user_cubit.dart';

class InviteUserState extends BaseState {
  const InviteUserState({
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  InviteUserState copyWith({StateStatus? status, String? errorMessage}) {
    return InviteUserState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
