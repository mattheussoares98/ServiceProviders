import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit_sections.dart';

part 'permissions_state.dart';

enum PermissionsSections implements SectionKey { save }

@injectable
class PermissionsCubit extends BaseCubit<PermissionsState> {
  PermissionsCubit() : super(const PermissionsState());
  // ============================================
  // ============================================
  // Group Permissions Logic
  // ============================================

  void initGroup(PermissionGroupEntity group) {
    final isAdminGroup = group.name.toLowerCase() == 'administrador';

    final localPermissions = <ResourceType, Set<PermissionAction>>{};
    for (final resource in ResourceType.values) {
      if (resource == ResourceType.workOrders) continue;
      final initialActions = <PermissionAction>{};
      if (isAdminGroup) {
        initialActions.addAll(PermissionAction.values);
      } else {
        final actions = group.permissions[resource];
        if (actions != null) {
          initialActions.addAll(actions);
        }
      }
      localPermissions[resource] = initialActions;
    }

    emit(
      PermissionsState(
        group: group,
        isAdmin: isAdminGroup,
        draftGroupPermissions: localPermissions,
        draftGroupWorkOrders: isAdminGroup
            ? const WorkOrdersPermissionEntity.defaultAdmin()
            : group.workOrders,
        status: DataStatus.loaded,
      ),
    );
  }

  void toggleGroupPermission(
    ResourceType resource,
    PermissionAction action,
    bool value,
  ) {
    if (state.isAdmin || resource == ResourceType.workOrders) return;

    final currentPermissions = Map<ResourceType, Set<PermissionAction>>.from(
      state.draftGroupPermissions,
    );

    final currentActions = Set<PermissionAction>.from(
      currentPermissions[resource] ?? {},
    );

    if (value) {
      currentActions.add(action);
    } else {
      currentActions.remove(action);
    }

    currentPermissions[resource] = currentActions;

    emit(state.copyWith(draftGroupPermissions: currentPermissions));
  }

  void changeGroupWorkOrdersReadScope(WorkOrderReadScope value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftGroupWorkOrders: state.draftGroupWorkOrders.copyWith(
          readScope: value,
        ),
      ),
    );
  }

  void toggleGroupWorkOrdersCreate(bool value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftGroupWorkOrders: state.draftGroupWorkOrders.copyWith(
          create: value,
        ),
      ),
    );
  }

  void changeGroupWorkOrdersUpdateScope(WorkOrderUpdateScope value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftGroupWorkOrders: state.draftGroupWorkOrders.copyWith(
          updateScope: value,
        ),
      ),
    );
  }

  void toggleGroupWorkOrdersDelete(bool value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftGroupWorkOrders: state.draftGroupWorkOrders.copyWith(
          delete: value,
        ),
      ),
    );
  }

  void toggleGroupWorkOrdersChangeStatus(bool value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftGroupWorkOrders: state.draftGroupWorkOrders.copyWith(
          changeStatus: value,
        ),
      ),
    );
  }

  void toggleGroupWorkOrdersReassign(bool value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftGroupWorkOrders: state.draftGroupWorkOrders.copyWith(
          reassign: value,
        ),
      ),
    );
  }

  void toggleGroupWorkOrdersmanagePendingRequests(bool value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftGroupWorkOrders: state.draftGroupWorkOrders.copyWith(
          managePendingRequests: value,
        ),
      ),
    );
  }

  void toggleGroupWorkOrdersDeleteObservation(bool value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftGroupWorkOrders: state.draftGroupWorkOrders.copyWith(
          deleteObservation: value,
        ),
      ),
    );
  }

  Future<bool> saveGroupPermissions(UsersCubit usersCubit) async {
    final group = state.group;
    if (group == null || state.isAdmin) return false;

    emit(
      state.copyWith(
        sections: withSection(
          PermissionsSections.save,
          SectionStatus.running,
        ),
      ),
    );

    final updatedPermissions = Map<ResourceType, Set<PermissionAction>>.from(
      state.draftGroupPermissions,
    )..removeWhere((key, value) => value.isEmpty);

    final updatedGroup = group.copyWith(
      permissions: updatedPermissions,
      workOrders: state.draftGroupWorkOrders,
    );

    final success = await usersCubit.savePermissionGroup(
      updatedGroup,
      isUpdate: true,
    );

    if (success) {
      emit(
        state.copyWith(
          group: updatedGroup,
          sections: withSection(
            PermissionsSections.save,
            SectionStatus.success,
          ),
        ),
      );
      return true;
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            PermissionsSections.save,
            SectionStatus.error,
          ),
        ),
      );
      return false;
    }
  }

  // ============================================
  // User Permissions Logic
  // ============================================

  void initUser(UserProfileEntity user) {
    final localOverrides = <ResourceType, Map<PermissionAction, bool?>>{};

    for (final resource in ResourceType.values) {
      if (resource == ResourceType.workOrders) continue;
      final resourceOverrides = <PermissionAction, bool?>{};
      for (final action in [
        PermissionAction.create,
        PermissionAction.update,
        PermissionAction.delete,
      ]) {
        resourceOverrides[action] = user.permissions[resource]?[action];
      }
      localOverrides[resource] = resourceOverrides;
    }

    emit(
      PermissionsState(
        user: user,
        isAdmin: user.isAdmin,
        selectedGroupId: user.permissionGroupId,
        draftUserPermissions: localOverrides,
        draftUserWorkOrders: user.workOrdersPermissionOverrides,
        status: DataStatus.loaded,
      ),
    );
  }

  bool isGroupAdmin(String? groupId, List<PermissionGroupEntity> groups) {
    if (groupId == null) return false;
    final group = groups.firstWhereOrNull((g) => g.id == groupId);
    return group?.name.toLowerCase() == 'administrador';
  }

  void changeUserGroup(String groupId, UsersCubit usersCubit) {
    final groups = usersCubit.state.permissionGroups;
    final isAdminGroup = isGroupAdmin(groupId, groups);

    if (isAdminGroup) {
      emit(
        state.copyWith(
          selectedGroupId: groupId,
          isAdmin: true,
          draftUserPermissions: const {},
          draftUserWorkOrders:
              const UserWorkOrdersPermissionOverrideEntity.empty(),
        ),
      );
    } else {
      emit(state.copyWith(selectedGroupId: groupId, isAdmin: false));
    }
  }

  void setUserPermissionOverride(
    ResourceType resource,
    PermissionAction action,
    bool? value,
  ) {
    if (state.isAdmin || resource == ResourceType.workOrders) return;

    final currentOverrides =
        Map<ResourceType, Map<PermissionAction, bool?>>.from(
          state.draftUserPermissions.map(
            (k, v) => MapEntry(k, Map<PermissionAction, bool?>.from(v)),
          ),
        );

    final resourceOverrides = Map<PermissionAction, bool?>.from(
      currentOverrides[resource] ?? {},
    );
    resourceOverrides[action] = value;
    currentOverrides[resource] = resourceOverrides;

    emit(state.copyWith(draftUserPermissions: currentOverrides));
  }

  void changeUserWorkOrdersReadScope(WorkOrderReadScope? value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftUserWorkOrders: state.draftUserWorkOrders.copyWith(
          readScope: value,
          annulReadScope: value == null,
        ),
      ),
    );
  }

  void toggleUserWorkOrdersCreate(bool? value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftUserWorkOrders: state.draftUserWorkOrders.copyWith(
          create: value,
          annulCreate: value == null,
        ),
      ),
    );
  }

  void changeUserWorkOrdersUpdateScope(WorkOrderUpdateScope? value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftUserWorkOrders: state.draftUserWorkOrders.copyWith(
          updateScope: value,
          annulUpdateScope: value == null,
        ),
      ),
    );
  }

  void toggleUserWorkOrdersDelete(bool? value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftUserWorkOrders: state.draftUserWorkOrders.copyWith(
          delete: value,
          annulDelete: value == null,
        ),
      ),
    );
  }

  void toggleUserWorkOrdersChangeStatus(bool? value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftUserWorkOrders: state.draftUserWorkOrders.copyWith(
          changeStatus: value,
          annulChangeStatus: value == null,
        ),
      ),
    );
  }

  void toggleUserWorkOrdersReassign(bool? value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftUserWorkOrders: state.draftUserWorkOrders.copyWith(
          reassign: value,
          annulReassign: value == null,
        ),
      ),
    );
  }

  void toggleUserWorkOrdersmanagePendingRequests(bool? value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftUserWorkOrders: state.draftUserWorkOrders.copyWith(
          managePendingRequests: value,
          annulManagePendingRequests: value == null,
        ),
      ),
    );
  }

  void toggleUserWorkOrdersDeleteObservation(bool? value) {
    if (state.isAdmin) return;
    emit(
      state.copyWith(
        draftUserWorkOrders: state.draftUserWorkOrders.copyWith(
          deleteObservation: value,
          annulDeleteObservation: value == null,
        ),
      ),
    );
  }

  Future<bool> saveUserPermissions(UsersCubit usersCubit) async {
    final user = state.user;
    if (user == null) return false;

    emit(
      state.copyWith(
        sections: withSection(
          PermissionsSections.save,
          SectionStatus.running,
        ),
      ),
    );

    final Map<ResourceType, Map<PermissionAction, bool?>> finalPermissions = {};

    state.draftUserPermissions.forEach((resource, actionMap) {
      final Map<PermissionAction, bool?> resourcePermissions = {};
      actionMap.forEach((action, value) {
        if (value != null) {
          resourcePermissions[action] = value;
        }
      });
      if (resourcePermissions.isNotEmpty) {
        finalPermissions[resource] = resourcePermissions;
      }
    });

    final updatedUser = user.copyWith(
      permissions: finalPermissions,
      permissionGroupId: state.selectedGroupId,
      workOrders: state.draftUserWorkOrders,
    );

    final success = await usersCubit.updateUserPermissions(
      user.id,
      finalPermissions,
      groupId: state.selectedGroupId,
      workOrders: state.draftUserWorkOrders,
    );

    if (success) {
      emit(
        state.copyWith(
          user: updatedUser,
          sections: withSection(
            PermissionsSections.save,
            SectionStatus.success,
          ),
        ),
      );
      return true;
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            PermissionsSections.save,
            SectionStatus.error,
          ),
        ),
      );
      return false;
    }
  }

  void popRoute() {
    popRouteAdaptively();
  }
}
