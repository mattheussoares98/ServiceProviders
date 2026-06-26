part of 'users_cubit.dart';

class UsersState extends BaseState {
  const UsersState({
    required this.users,
    required this.permissionGroups,
    this.deletingUserIds = const {},
    this.deletingGroupIds = const {},
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const UsersState.initial()
    : users = const [],
      permissionGroups = const [],
      deletingUserIds = const {},
      deletingGroupIds = const {},
      super(status: StateStatus.initial, errorMessage: '');

  const UsersState.empty()
    : users = const [],
      permissionGroups = const [],
      deletingUserIds = const {},
      deletingGroupIds = const {},
      super(status: StateStatus.initial, errorMessage: '');

  final List<UserProfileEntity> users;
  final List<PermissionGroupEntity> permissionGroups;
  final Set<String> deletingUserIds;
  final Set<String> deletingGroupIds;

  UsersState copyWith({
    List<UserProfileEntity>? users,
    List<PermissionGroupEntity>? permissionGroups,
    Set<String>? deletingUserIds,
    Set<String>? deletingGroupIds,
    StateStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
  }) {
    return UsersState(
      users: users ?? this.users,
      permissionGroups: permissionGroups ?? this.permissionGroups,
      deletingUserIds: deletingUserIds ?? this.deletingUserIds,
      deletingGroupIds: deletingGroupIds ?? this.deletingGroupIds,
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
    deletingUserIds,
    deletingGroupIds,
    status,
    errorMessage,
  ];
}