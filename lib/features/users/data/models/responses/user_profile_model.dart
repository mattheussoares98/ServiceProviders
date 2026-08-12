import 'dart:convert';

import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileModel extends UserProfileEntity
    implements DataConvertible<UserProfileEntity> {
  const UserProfileModel({
    required super.id,
    required super.companyId,
    required super.name,
    required super.email,
    super.phone,
    super.permissionGroupId,
    super.avatarUrl,
    required super.isActive,
    required super.isAdmin,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    super.permissions,
    super.workOrdersPermissionOverrides,
  });

  factory UserProfileModel.fromEntity(UserProfileEntity entity) =>
      UserProfileModel(
        id: entity.id,
        companyId: entity.companyId,
        name: entity.name,
        email: entity.email,
        phone: entity.phone,
        permissionGroupId: entity.permissionGroupId,
        avatarUrl: entity.avatarUrl,
        isActive: entity.isActive,
        isAdmin: entity.isAdmin,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        deletedAt: entity.deletedAt,
        permissions: entity.permissions,
        workOrdersPermissionOverrides: entity.workOrdersPermissionOverrides,
      );

  factory UserProfileModel.fromDb(UserProfile db) {
    final parsed = _parsePermissions(db.permissions);
    return UserProfileModel(
      id: db.id,
      companyId: db.companyId,
      name: db.name,
      email: db.email,
      phone: db.phone,
      permissionGroupId: db.permissionGroupId,
      avatarUrl: db.avatarUrl,
      isActive: db.isActive,
      isAdmin: db.isAdmin,
      createdAt: db.createdAt,
      updatedAt: db.updatedAt,
      deletedAt: db.deletedAt,
      permissions: parsed.$1,
      workOrdersPermissionOverrides: parsed.$2,
    );
  }

  factory UserProfileModel.fromSupabase(AuthResponse response) {
    final now = DateTime.now();

    return UserProfileModel(
      id: response.user!.id,
      companyId: '',
      name: response.user!.userMetadata?['name'] as String? ?? '',
      email: response.user!.email ?? '',
      isAdmin: response.user!.userMetadata?['is_admin'] as bool? ?? false,
      isActive: true,
      createdAt: DateTime.tryParse(response.user?.createdAt ?? '') ?? now,
      updatedAt: DateTime.tryParse(response.user?.updatedAt ?? '') ?? now,
    );
  }

  factory UserProfileModel.fromServiceProviderJson(
    MapDynamic json,
    String authUserId,
  ) {
    return UserProfileModel(
      id: authUserId,
      companyId: '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isAdmin: false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  factory UserProfileModel.fromJson(MapDynamic json) {
    final parsed = _parsePermissions(json['permissions']);
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      permissionGroupId: json['permission_group_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      permissions: parsed.$1,
      workOrdersPermissionOverrides: parsed.$2,
    );
  }

  @override
  MapDynamic toJson() {
    final Map<String, dynamic> flatPermissions = {};
    permissions.forEach((resource, actionMap) {
      actionMap.forEach((action, isAllowed) {
        if (isAllowed != null) {
          flatPermissions['${resource.code}.${action.code}'] = isAllowed;
        }
      });
    });

    if (workOrdersPermissionOverrides.readScope != null) {
      flatPermissions['work_orders.read_scope'] =
          workOrdersPermissionOverrides.readScope!.code;
    }
    if (workOrdersPermissionOverrides.create != null) {
      flatPermissions['work_orders.create'] =
          workOrdersPermissionOverrides.create;
    }
    if (workOrdersPermissionOverrides.updateScope != null) {
      flatPermissions['work_orders.update_scope'] =
          workOrdersPermissionOverrides.updateScope!.code;
    }
    if (workOrdersPermissionOverrides.delete != null) {
      flatPermissions['work_orders.delete'] =
          workOrdersPermissionOverrides.delete;
    }
    if (workOrdersPermissionOverrides.changeStatus != null) {
      flatPermissions['work_orders.change_status'] =
          workOrdersPermissionOverrides.changeStatus;
    }
    if (workOrdersPermissionOverrides.reassign != null) {
      flatPermissions['work_orders.reassign'] =
          workOrdersPermissionOverrides.reassign;
    }
    if (workOrdersPermissionOverrides.approvePause != null) {
      flatPermissions['work_orders.approve_pause'] =
          workOrdersPermissionOverrides.approvePause;
    }
    if (workOrdersPermissionOverrides.approveCompletion != null) {
      flatPermissions['work_orders.approve_completion'] =
          workOrdersPermissionOverrides.approveCompletion;
    }

    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'email': email,
      'phone': phone,
      'permission_group_id': permissionGroupId,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'is_admin': isAdmin,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'permissions': flatPermissions,
    };
  }

  @override
  UserProfileEntity toEntity() => UserProfileEntity(
    id: id,
    companyId: companyId,
    name: name,
    email: email,
    phone: phone,
    permissionGroupId: permissionGroupId,
    avatarUrl: avatarUrl,
    isActive: isActive,
    isAdmin: isAdmin,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    permissions: permissions,
    workOrdersPermissionOverrides: workOrdersPermissionOverrides,
  );

  static (
    Map<ResourceType, Map<PermissionAction, bool?>>,
    UserWorkOrdersPermissionOverrideEntity,
  )
  _parsePermissions(dynamic permissionsRaw) {
    final Map<ResourceType, Map<PermissionAction, bool?>> structured = {};
    UserWorkOrdersPermissionOverrideEntity workOrders =
        const UserWorkOrdersPermissionOverrideEntity.empty();

    if (permissionsRaw != null) {
      dynamic decoded;
      if (permissionsRaw is String) {
        try {
          decoded = jsonDecode(permissionsRaw);
        } catch (_) {}
      } else {
        decoded = permissionsRaw;
      }

      if (decoded is Map) {
        // Standard resources
        for (final resource in ResourceType.values) {
          if (resource == ResourceType.workOrders) continue;
          final Map<PermissionAction, bool?> actionMap = {};
          for (final action in [
            PermissionAction.create,
            PermissionAction.update,
            PermissionAction.delete,
          ]) {
            final key = '${resource.code}.${action.code}';
            if (decoded.containsKey(key)) {
              actionMap[action] = decoded[key] as bool?;
            }
          }
          if (actionMap.isNotEmpty) {
            structured[resource] = actionMap;
          }
        }

        // Work orders overrides
        WorkOrderReadScope? readScope;
        if (decoded.containsKey('work_orders.read_scope')) {
          final val = decoded['work_orders.read_scope'] as String?;
          if (val != null) {
            readScope = WorkOrderReadScope.fromCode(val);
          }
        }

        WorkOrderUpdateScope? updateScope;
        if (decoded.containsKey('work_orders.update_scope')) {
          final val = decoded['work_orders.update_scope'] as String?;
          if (val != null) {
            updateScope = WorkOrderUpdateScope.fromCode(val);
          }
        }

        final bool? create = decoded['work_orders.create'] as bool?;
        final bool? delete = decoded['work_orders.delete'] as bool?;
        final bool? changeStatus =
            decoded['work_orders.change_status'] as bool?;
        final bool? reassign = decoded['work_orders.reassign'] as bool?;
        final bool? approvePause =
            decoded['work_orders.approve_pause'] as bool?;
        final bool? approveCompletion =
            decoded['work_orders.approve_completion'] as bool?;

        workOrders = UserWorkOrdersPermissionOverrideEntity(
          readScope: readScope,
          create: create,
          updateScope: updateScope,
          delete: delete,
          changeStatus: changeStatus,
          reassign: reassign,
          approvePause: approvePause,
          approveCompletion: approveCompletion,
          deleteObservation: null,
        );
      }
    }

    return (structured, workOrders);
  }
}
