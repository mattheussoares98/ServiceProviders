import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'permissions_state.dart';

@injectable
class PermissionsCubit extends BaseCubit<PermissionsState> {
  PermissionsCubit() : super(const PermissionsState());
  //TODO check if we can change this code to be easier to understand
  // ============================================
  // Group Permissions Logic
  // ============================================

  void initGroup(PermissionGroupEntity group) {
    final isAdminGroup = group.name.toLowerCase() == 'administrador';

    final localPermissions = <ResourceType, Set<PermissionAction>>{};
    for (final resource in ResourceType.values) {
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
        status: StateStatus.loaded,
      ),
    );
  }

  void toggleGroupPermission(
    ResourceType resource,
    PermissionAction action,
    bool value,
  ) {
    if (state.isAdmin) return;

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

  Future<bool> saveGroupPermissions(UsersCubit usersCubit) async {
    final group = state.group;
    if (group == null || state.isAdmin) return false;

    emit(state.copyWith(status: StateStatus.saving));

    final updatedPermissions = Map<ResourceType, Set<PermissionAction>>.from(
      state.draftGroupPermissions,
    )..removeWhere((key, value) => value.isEmpty);

    final updatedGroup = group.copyWith(permissions: updatedPermissions);

    final success = await usersCubit.savePermissionGroup(
      updatedGroup,
      isUpdate: true,
    );

    if (success) {
      emit(state.copyWith(group: updatedGroup, status: StateStatus.loaded));
      return true;
    } else {
      //not emiting error because it is already handling in the users cubit
      //this cubit here just validate and call the service
      emit(state.copyWith(status: StateStatus.loaded));
      return false;
    }
  }

  // ============================================
  // User Permissions Logic
  // ============================================

  void initUser(UserProfileEntity user) {
    final localOverrides = <ResourceType, Map<PermissionAction, bool?>>{};

    for (final resource in ResourceType.values) {
      final resourceOverrides = <PermissionAction, bool?>{};
      for (final action in PermissionAction.values) {
        resourceOverrides[action] = user.permissions[resource]?[action];
      }
      localOverrides[resource] = resourceOverrides;
    }

    emit(
      PermissionsState(
        user: user,
        isAdmin: user.isAdmin,
        draftUserPermissions: localOverrides,
        status: StateStatus.loaded,
      ),
    );
  }

  void setUserPermissionOverride(
    ResourceType resource,
    PermissionAction action,
    bool? value,
  ) {
    if (state.isAdmin) return;

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

  Future<bool> saveUserPermissions(UsersCubit usersCubit) async {
    final user = state.user;
    if (user == null || state.isAdmin) return false;

    emit(state.copyWith(status: StateStatus.saving));

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

    final updatedUser = user.copyWith(permissions: finalPermissions);

    final success = await usersCubit.updateUserProfile(updatedUser);

    if (success) {
      emit(state.copyWith(user: updatedUser, status: StateStatus.loaded));
      return true;
    } else {
      emit(state.copyWith(status: StateStatus.loadingError));
      return false;
    }
  }
}
