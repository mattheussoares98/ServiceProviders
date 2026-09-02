part of 'permissions_cubit.dart';

class PermissionsState extends BaseState {
  const PermissionsState({
    this.group,
    this.user,
    this.isAdmin = false,
    this.selectedGroupId,
    this.draftGroupPermissions = const {},
    this.draftUserPermissions = const {},
    this.draftGroupWorkOrders =
        const WorkOrdersPermissionEntity.defaultTechnical(),
    this.draftUserWorkOrders =
        const UserWorkOrdersPermissionOverrideEntity.empty(),
    super.sections = const {},
  });

  final PermissionGroupEntity? group;
  final UserProfileEntity? user;
  final bool isAdmin;
  final String? selectedGroupId;

  // For group permissions: ResourceType -> Set of actions
  final Map<ResourceType, Set<PermissionAction>> draftGroupPermissions;

  // For user permissions: ResourceType -> Map of actions to overrides (true = active, false = inactive, null = inherit)
  final Map<ResourceType, Map<PermissionAction, bool?>> draftUserPermissions;

  // Work Orders permissions for groups
  final WorkOrdersPermissionEntity draftGroupWorkOrders;

  // Work Orders overrides for users
  final UserWorkOrdersPermissionOverrideEntity draftUserWorkOrders;

  PermissionsState copyWith({
    PermissionGroupEntity? group,
    UserProfileEntity? user,
    bool? isAdmin,
    String? selectedGroupId,
    Map<ResourceType, Set<PermissionAction>>? draftGroupPermissions,
    Map<ResourceType, Map<PermissionAction, bool?>>? draftUserPermissions,
    WorkOrdersPermissionEntity? draftGroupWorkOrders,
    UserWorkOrdersPermissionOverrideEntity? draftUserWorkOrders,
    bool? annulSelectedGroupId,
    Map<SectionKey, SectionState>? sections,
  }) {
    return PermissionsState(
      group: group ?? this.group,
      user: user ?? this.user,
      isAdmin: isAdmin ?? this.isAdmin,
      selectedGroupId: annulSelectedGroupId == true
          ? null
          : selectedGroupId ?? this.selectedGroupId,
      draftGroupPermissions:
          draftGroupPermissions ?? this.draftGroupPermissions,
      draftUserPermissions: draftUserPermissions ?? this.draftUserPermissions,
      draftGroupWorkOrders: draftGroupWorkOrders ?? this.draftGroupWorkOrders,
      draftUserWorkOrders: draftUserWorkOrders ?? this.draftUserWorkOrders,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    group,
    user,
    isAdmin,
    selectedGroupId,
    draftGroupPermissions,
    draftUserPermissions,
    draftGroupWorkOrders,
    draftUserWorkOrders,
    sections,
  ];
}
