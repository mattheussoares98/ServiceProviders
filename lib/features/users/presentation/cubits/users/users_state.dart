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
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const UsersState.initial()
    : users = const [],
      permissionGroups = const [],
      invitations = const [],
      deletingUserIds = const {},
      deletingGroupIds = const {},
      deletingInvitationIds = const {},
      resendingInvitationIds = const {},
      super(status: StateStatus.initial, errorMessage: '');

  const UsersState.empty()
    : users = const [],
      permissionGroups = const [],
      invitations = const [],
      deletingUserIds = const {},
      deletingGroupIds = const {},
      deletingInvitationIds = const {},
      resendingInvitationIds = const {},
      super(status: StateStatus.initial, errorMessage: '');

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
    StateStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
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
  ];
}
