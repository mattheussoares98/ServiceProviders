import 'dart:convert';

import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileResponseModel extends UserProfileEntity
    implements DataConvertible<UserProfileEntity> {
  const UserProfileResponseModel({
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
  });

  factory UserProfileResponseModel.fromEntity(UserProfileEntity entity) =>
      UserProfileResponseModel(
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
      );

  factory UserProfileResponseModel.fromDb(UserProfile db) =>
      UserProfileResponseModel(
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
        permissions: _parsePermissionsFromDb(db.permissions),
      );

  factory UserProfileResponseModel.fromSupabase(AuthResponse response) {
    final now = DateTime.now();

    return UserProfileResponseModel(
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

  factory UserProfileResponseModel.fromJson(MapDynamic json) =>
      UserProfileResponseModel(
        id: json['id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
        permissionGroupId: json['permission_group_id'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
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
        permissions: _parsePermissionsFromJson(json['permissions']),
      );

  @override
  MapDynamic toJson() {
    final Map<String, bool> flatPermissions = {};
    permissions.forEach((resource, actionMap) {
      actionMap.forEach((action, isAllowed) {
        if (isAllowed != null) {
          flatPermissions['${resource.code}.${action.code}'] = isAllowed;
        }
      });
    });

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
  );

  static Map<ResourceType, Map<PermissionAction, bool?>>
  _parsePermissionsFromDb(String? permissionsStr) {
    if (permissionsStr == null || permissionsStr.isEmpty) return const {};
    try {
      final decoded = jsonDecode(permissionsStr) as Map<dynamic, dynamic>;
      return _mapToStructuredPermissions(decoded);
    } catch (_) {
      return const {};
    }
  }

  static Map<ResourceType, Map<PermissionAction, bool?>>
  _parsePermissionsFromJson(dynamic permissionsRaw) {
    if (permissionsRaw == null) return const {};
    if (permissionsRaw is Map) {
      return _mapToStructuredPermissions(permissionsRaw);
    }
    if (permissionsRaw is String) {
      try {
        final decoded = jsonDecode(permissionsRaw) as Map<dynamic, dynamic>;
        return _mapToStructuredPermissions(decoded);
      } catch (_) {}
    }
    return const {};
  }

  static Map<ResourceType, Map<PermissionAction, bool?>>
  _mapToStructuredPermissions(Map<dynamic, dynamic> rawMap) {
    final Map<ResourceType, Map<PermissionAction, bool?>> structured = {};
    //TODO save a  Map<ResourceType, Map<PermissionAction, bool?>> instead of raw data
    rawMap.forEach((key, value) {
      final keyStr = key.toString();
      final isAllowed = value as bool?;
      final parts = keyStr.split(RegExp('[:.]'));

      if (parts.length == 2) {
        final resource = ResourceType.fromCode(parts[0]);
        PermissionAction? action;
        final actionStr = parts[1];

        if (actionStr == 'create') {
          action = PermissionAction.create;
        } else if (actionStr == 'read' ||
            actionStr == 'view' ||
            actionStr == 'view_assigned') {
          action = PermissionAction.read;
        } else if (actionStr == 'update' ||
            actionStr == 'update_status' ||
            actionStr == 'fill') {
          action = PermissionAction.update;
        } else if (actionStr == 'delete') {
          action = PermissionAction.delete;
        }

        if (resource != null && action != null) {
          structured.putIfAbsent(resource, () => {})[action] = isAllowed;
        }
      }
    });

    return structured;
  }
}
