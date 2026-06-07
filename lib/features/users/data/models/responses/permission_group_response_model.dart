import 'dart:convert';
import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';

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

  factory PermissionGroupResponseModel.fromEntity(PermissionGroupEntity entity) =>
      PermissionGroupResponseModel(
        id: entity.id,
        companyId: entity.companyId,
        name: entity.name,
        permissions: entity.permissions,
        isDefault: entity.isDefault,
        createdAt: entity.createdAt,
        deletedAt: entity.deletedAt,
      );

  factory PermissionGroupResponseModel.fromJson(MapDynamic json) {
    final Map<ResourceType, Set<PermissionAction>> grouped = {};

    void addAllActionsForResource(ResourceType resource) {
      grouped.putIfAbsent(resource, () => {}).addAll(PermissionAction.values);
    }

    if (json['permissions'] != null) {
      final permissionsRaw = json['permissions'];
      List<dynamic> list = [];
      if (permissionsRaw is String) {
        try {
          list = jsonDecode(permissionsRaw) as List<dynamic>;
        } catch (_) {}
      } else if (permissionsRaw is List) {
        list = permissionsRaw;
      }
      for (final p in list) {
        final code = p.toString();
        if (code == '*') {
          for (final res in ResourceType.values) {
            addAllActionsForResource(res);
          }
        } else if (code.endsWith('.*') || code.endsWith(':*')) {
          final prefix = code.substring(0, code.length - 2);
          final resource = ResourceType.fromCode(prefix);
          if (resource != null) {
            addAllActionsForResource(resource);
          }
        } else {
          final parts = code.split(RegExp(r'[:.]'));
          if (parts.length == 2) {
            final resource = ResourceType.fromCode(parts[0]);
            PermissionAction? action = PermissionAction.fromCode(parts[1]);
            if (parts[1] == 'view') {
              action = PermissionAction.read;
            }
            if (resource != null && action != null) {
              grouped.putIfAbsent(resource, () => {}).add(action);
            }
          }
        }
      }
    }

    final permissions = grouped.entries
        .map((e) => ResourcePermissionEntity(resource: e.key, actions: e.value))
        .toList();

    return PermissionGroupResponseModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      permissions: permissions,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  @override
  MapDynamic toJson() => {
        'id': id,
        'company_id': companyId,
        'name': name,
        'permissions': permissions.expand((rp) {
          return rp.actions.map((action) => '${rp.resource.code}.${action.code}');
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
