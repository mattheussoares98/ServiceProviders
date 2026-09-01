part of 'invite_user_cubit.dart';

class InviteUserState extends BaseState {
  const InviteUserState({
    super.status = DataStatus.initial,
    super.errorMessage = '',
    super.sections = const {},
  });

  InviteUserState copyWith({
    DataStatus? status,
    String? errorMessage,
    Map<SectionKey, SectionStatus>? sections,
  }) {
    return InviteUserState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, sections];
}
