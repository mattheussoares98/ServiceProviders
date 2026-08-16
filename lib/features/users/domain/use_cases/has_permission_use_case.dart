import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_sub_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_permission_groups_use_case.dart';

class HasPermissionParams extends Equatable {
  const HasPermissionParams({
    required this.permission,
    this.user,
    this.permissionGroups,
  });

  final ActionPermission permission;
  final UserProfileEntity? user;
  final List<PermissionGroupEntity>? permissionGroups;

  @override
  List<Object?> get props => [permission, user, permissionGroups];
}

@LazySingleton()
class HasPermissionUseCase implements UseCase<bool, HasPermissionParams> {
  HasPermissionUseCase({
    required GetSessionUserUseCase getSessionUser,
    required GetPermissionGroupsUseCase getPermissionGroups,
    required GetActiveCompanyIdUseCase getActiveCompanyId,
  }) : _getSessionUser = getSessionUser,
       _getPermissionGroups = getPermissionGroups,
       _getActiveCompanyId = getActiveCompanyId;

  final GetSessionUserUseCase _getSessionUser;
  final GetPermissionGroupsUseCase _getPermissionGroups;
  final GetActiveCompanyIdUseCase _getActiveCompanyId;

  @override
  FutureBool call(HasPermissionParams request) async {
    final user = request.user ?? _getSessionUser();
    if (user.isAdmin) {
      return const SuccessState(data: true);
    }

    List<PermissionGroupEntity>? groups = request.permissionGroups;
    if (groups == null && user.permissionGroupId != null) {
      final companyId = _getActiveCompanyId();
      if (companyId.isNotEmpty) {
        final groupsResult = await _getPermissionGroups(companyId);
        if (groupsResult is SuccessState<List<PermissionGroupEntity>>) {
          groups = groupsResult.data;
        }
      }
    }

    final hasPerm = evaluatePermission(
      permission: request.permission,
      user: user,
      permissionGroups: groups ?? const [],
    );

    return SuccessState(data: hasPerm);
  }

  static bool evaluatePermission({
    required ActionPermission permission,
    required UserProfileEntity user,
    required List<PermissionGroupEntity> permissionGroups,
  }) {
    if (user.isAdmin) return true;

    return switch (permission) {
      ResourceActionPermission(
        resourceType: final resource,
        permissionAction: final action,
      ) =>
        _hasResourcePermission(
          resource: resource,
          action: action,
          user: user,
          permissionGroups: permissionGroups,
        ),
      WorkOrderSubActionPermission(:final subAction) =>
        _hasWorkOrderSubActionPermission(
          subAction: subAction,
          user: user,
          permissionGroups: permissionGroups,
        ),
    };
  }

  static bool _hasWorkOrderSubActionPermission({
    required WorkOrderSubAction subAction,
    required UserProfileEntity user,
    required List<PermissionGroupEntity> permissionGroups,
  }) {
    if (user.isAdmin) return true;

    final woPermissions = user.workOrdersPermissionOverrides;
    final groupPermissions = permissionGroups
        .firstWhereOrNull((g) => g.id == user.permissionGroupId)
        ?.workOrders;

    switch (subAction) {
      case WorkOrderSubAction.deleteObservation:
        final override = woPermissions.deleteObservation;
        if (override != null) return override;
        return groupPermissions?.deleteObservation ?? false;

      case WorkOrderSubAction.changeStatus:
        final override = woPermissions.changeStatus;
        if (override != null) return override;
        return groupPermissions?.changeStatus ?? false;

      case WorkOrderSubAction.reassign:
        final override = woPermissions.reassign;
        if (override != null) return override;
        return groupPermissions?.reassign ?? false;

      case WorkOrderSubAction.managePendingRequests:
        final override = woPermissions.managePendingRequests;
        if (override != null) return override;
        return groupPermissions?.managePendingRequests ?? false;
    }
  }

  static bool _hasResourcePermission({
    required ResourceType resource,
    required PermissionAction action,
    required UserProfileEntity user,
    required List<PermissionGroupEntity> permissionGroups,
  }) {
    if (user.isAdmin) return true;

    if (resource == ResourceType.workOrders) {
      final woPermissions = user.workOrdersPermissionOverrides;
      final groupPermissions = permissionGroups
          .firstWhereOrNull((g) => g.id == user.permissionGroupId)
          ?.workOrders;

      if (action == PermissionAction.create) {
        if (woPermissions.create != null) return woPermissions.create!;
        if (groupPermissions?.create == true) return true;
      } else if (action == PermissionAction.delete) {
        if (woPermissions.delete != null) return woPermissions.delete!;
        if (groupPermissions?.delete == true) return true;
      }
    }

    final userOverride = user.permissions[resource]?[action];
    if (userOverride != null) {
      return userOverride;
    }

    final groupId = user.permissionGroupId;
    if (groupId == null || groupId.isEmpty) return false;

    final group = permissionGroups.firstWhereOrNull((g) => g.id == groupId);
    if (group != null) {
      return group.permissions[resource]?.contains(action) ?? false;
    }

    return false;
  }
}
