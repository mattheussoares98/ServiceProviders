part of 'users_cubit.dart';

class UsersState extends BaseState {
  const UsersState({
    required this.users,
    required this.permissionGroups,
    this.invitations = const [],
    this.deletingUserIds = const {},
    this.deletingGroupIds = const {},
    this.deletingInvitationIds = const {},
    this.resendingInvitationIds = const {},
    super.status = DataStatus.initial,
    super.errorMessage = '',
    super.sections = const {},
  });

  const UsersState.initial()
    : users = const [],
      permissionGroups = const [],
      invitations = const [],
      deletingUserIds = const {},
      deletingGroupIds = const {},
      deletingInvitationIds = const {},
      resendingInvitationIds = const {},
      super(status: DataStatus.initial, errorMessage: '');

  const UsersState.empty()
    : users = const [],
      permissionGroups = const [],
      invitations = const [],
      deletingUserIds = const {},
      deletingGroupIds = const {},
      deletingInvitationIds = const {},
      resendingInvitationIds = const {},
      super(status: DataStatus.initial, errorMessage: '');

  final List<UserProfileEntity> users;
  final List<PermissionGroupEntity> permissionGroups;
  final List<UserInvitationEntity> invitations;
  final Set<String> deletingUserIds;
  final Set<String> deletingGroupIds;
  final Set<String> deletingInvitationIds;
  final Set<String> resendingInvitationIds;

  UsersState copyWith({
    List<UserProfileEntity>? users,
    List<PermissionGroupEntity>? permissionGroups,
    List<UserInvitationEntity>? invitations,
    Set<String>? deletingUserIds,
    Set<String>? deletingGroupIds,
    Set<String>? deletingInvitationIds,
    Set<String>? resendingInvitationIds,
    DataStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
    Map<SectionKey, SectionStatus>? sections,
  }) {
    return UsersState(
      users: users ?? this.users,
      permissionGroups: permissionGroups ?? this.permissionGroups,
      invitations: invitations ?? this.invitations,
      deletingUserIds: deletingUserIds ?? this.deletingUserIds,
      deletingGroupIds: deletingGroupIds ?? this.deletingGroupIds,
      deletingInvitationIds:
          deletingInvitationIds ?? this.deletingInvitationIds,
      resendingInvitationIds:
          resendingInvitationIds ?? this.resendingInvitationIds,
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    users,
    permissionGroups,
    invitations,
    deletingUserIds,
    deletingGroupIds,
    deletingInvitationIds,
    resendingInvitationIds,
    status,
    errorMessage,
    sections,
  ];
}
