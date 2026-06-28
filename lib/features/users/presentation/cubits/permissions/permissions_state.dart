part of 'permissions_cubit.dart';

class PermissionsState extends BaseState {
  const PermissionsState({
    this.group,
    this.user,
    this.isAdmin = false,
    this.draftGroupPermissions = const {},
    this.draftUserPermissions = const {},
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  final PermissionGroupEntity? group;
  final UserProfileEntity? user;
  final bool isAdmin;
  
  // For group permissions: ResourceType -> Set of actions
  final Map<ResourceType, Set<PermissionAction>> draftGroupPermissions;
  
  // For user permissions: ResourceType -> Map of actions to overrides (true = active, false = inactive, null = inherit)
  final Map<ResourceType, Map<PermissionAction, bool?>> draftUserPermissions;

  PermissionsState copyWith({
    PermissionGroupEntity? group,
    UserProfileEntity? user,
    bool? isAdmin,
    Map<ResourceType, Set<PermissionAction>>? draftGroupPermissions,
    Map<ResourceType, Map<PermissionAction, bool?>>? draftUserPermissions,
    StateStatus? status,
    String? errorMessage,
  }) {
    return PermissionsState(
      group: group ?? this.group,
      user: user ?? this.user,
      isAdmin: isAdmin ?? this.isAdmin,
      draftGroupPermissions:
          draftGroupPermissions ?? this.draftGroupPermissions,
      draftUserPermissions: draftUserPermissions ?? this.draftUserPermissions,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        group,
        user,
        isAdmin,
        draftGroupPermissions,
        draftUserPermissions,
        status,
        errorMessage,
      ];
}
