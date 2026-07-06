import 'dart:convert';

import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';

class PermissionGroupResponseModel extends PermissionGroupEntity
    implements DataConvertible<PermissionGroupEntity> {
  const PermissionGroupResponseModel({
    required super.id,
    required super.companyId,
    required super.name,
    required super.permissions,
    required super.isDefault,
    required super.createdAt,
    super.deletedAt,
  });

  factory PermissionGroupResponseModel.fromEntity(
    PermissionGroupEntity entity,
  ) => PermissionGroupResponseModel(
    id: entity.id,
    companyId: entity.companyId,
    name: entity.name,
    permissions: entity.permissions,
    isDefault: entity.isDefault,
    createdAt: entity.createdAt,
    deletedAt: entity.deletedAt,
  );

  factory PermissionGroupResponseModel.fromDb(PermissionGroup db) {
    return PermissionGroupResponseModel(
      id: db.id,
      companyId: db.companyId,
      name: db.name,
      permissions: _parsePermissions(db.permissions),
      isDefault: db.isDefault,
      createdAt: db.createdAt,
      deletedAt: db.deletedAt,
    );
  }

  factory PermissionGroupResponseModel.fromJson(MapDynamic json) {
    return PermissionGroupResponseModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      permissions: _parsePermissions(json['permissions']),
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  static Map<ResourceType, Set<PermissionAction>> _parsePermissions(
    dynamic permissionsRaw,
  ) {
    final Map<ResourceType, Set<PermissionAction>> grouped = {};

    void addAllActionsForResource(ResourceType resource) {
      grouped.putIfAbsent(resource, () => {}).addAll(PermissionAction.values);
    }

    if (permissionsRaw != null) {
      List<dynamic> list = [];
      if (permissionsRaw is String) {
        try {
          list = jsonDecode(permissionsRaw) as List<dynamic>;
        } catch (_) {}
      } else if (permissionsRaw is List) {
        list = permissionsRaw;
      }
      //TODO change to use the same pattern of Map<ResourceType, Set<PermissionAction>>
      for (final p in list) {
        final code = p.toString();
        if (code == '*') {
          ResourceType.values.forEach(addAllActionsForResource);
        } else if (code.endsWith('.*') || code.endsWith(':*')) {
          final prefix = code.substring(0, code.length - 2);
          final resource = ResourceType.fromCode(prefix);
          if (resource != null) {
            addAllActionsForResource(resource);
          }
        } else {
          final parts = code.split(RegExp('[:.]'));
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
              grouped.putIfAbsent(resource, () => {}).add(action);
            }
          }
        }
      }
    }

    return grouped;
  }

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'name': name,
    'permissions': permissions.entries.expand((e) {
      return e.value.map((action) => '${e.key.code}.${action.code}');
    }).toList(),
    'is_default': isDefault,
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };

  @override
  PermissionGroupEntity toEntity() => PermissionGroupEntity(
    id: id,
    companyId: companyId,
    name: name,
    permissions: permissions,
    isDefault: isDefault,
    createdAt: createdAt,
    deletedAt: deletedAt,
  );
}
