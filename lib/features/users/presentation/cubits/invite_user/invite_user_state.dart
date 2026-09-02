part of 'invite_user_cubit.dart';

class InviteUserState extends BaseState {
  const InviteUserState({
    super.sections = const {},
  });

  InviteUserState copyWith({
    Map<SectionKey, SectionState>? sections,
  }) {
    return InviteUserState(
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [sections];
}
