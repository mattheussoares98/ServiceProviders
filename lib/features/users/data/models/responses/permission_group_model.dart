import 'dart:convert';

import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';

class PermissionGroupModel extends PermissionGroupEntity
    implements DataConvertible<PermissionGroupEntity> {
  const PermissionGroupModel({
    required super.id,
    required super.companyId,
    required super.name,
    required super.permissions,
    required super.workOrders,
    required super.isDefault,
    required super.createdAt,
    super.deletedAt,
  });

  factory PermissionGroupModel.fromEntity(PermissionGroupEntity entity) =>
      PermissionGroupModel(
        id: entity.id,
        companyId: entity.companyId,
        name: entity.name,
        permissions: entity.permissions,
        workOrders: entity.workOrders,
        isDefault: entity.isDefault,
        createdAt: entity.createdAt,
        deletedAt: entity.deletedAt,
      );

  factory PermissionGroupModel.fromDb(PermissionGroup db) {
    final parsed = _parsePermissions(db.permissions);
    return PermissionGroupModel(
      id: db.id,
      companyId: db.companyId,
      name: db.name,
      permissions: parsed.$1,
      workOrders: parsed.$2,
      isDefault: db.isDefault,
      createdAt: db.createdAt.toUtc(),
      deletedAt: db.deletedAt?.toUtc(),
    );
  }

  factory PermissionGroupModel.fromJson(MapDynamic json) {
    final parsed = _parsePermissions(json['permissions']);
    return PermissionGroupModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      permissions: parsed.$1,
      workOrders: parsed.$2,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: (json['created_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
    );
  }

  static (Map<ResourceType, Set<PermissionAction>>, WorkOrdersPermissionEntity)
  _parsePermissions(dynamic permissionsRaw) {
    final Map<ResourceType, Set<PermissionAction>> grouped = {};
    WorkOrdersPermissionEntity workOrders =
        const WorkOrdersPermissionEntity.defaultTechnical();

    void addAllActionsForResource(ResourceType resource) {
      grouped.putIfAbsent(resource, () => {}).addAll(PermissionAction.values);
    }

    if (permissionsRaw != null) {
      dynamic data;
      if (permissionsRaw is String) {
        try {
          data = jsonDecode(permissionsRaw);
        } catch (_) {}
      } else {
        data = permissionsRaw;
      }

      if (data is Map) {
        // Parse the new JSON object structure
        for (final resource in ResourceType.values) {
          if (resource == ResourceType.workOrders) continue;
          final actions = <PermissionAction>{};
          for (final action in [
            PermissionAction.create,
            PermissionAction.read,
            PermissionAction.update,
            PermissionAction.delete,
          ]) {
            final key = '${resource.code}.${action.code}';
            if (data[key] == true) {
              actions.add(action);
            }
          }
          if (actions.isNotEmpty) {
            grouped[resource] = actions;
          }
        }

        final isSuperAdmin = data['*'] == true;
        if (isSuperAdmin) {
          for (final resource in ResourceType.values) {
            if (resource == ResourceType.workOrders) continue;
            grouped[resource] = {
              PermissionAction.create,
              PermissionAction.update,
              PermissionAction.delete,
            };
          }
          workOrders = const WorkOrdersPermissionEntity.defaultAdmin();
        } else {
          final readScope = WorkOrderReadScope.fromCode(
            data['work_orders.read_scope'] as String?,
          );
          final create = data['work_orders.create'] == true;
          final updateScope = WorkOrderUpdateScope.fromCode(
            data['work_orders.update_scope'] as String?,
          );
          final delete = data['work_orders.delete'] == true;
          final changeStatus = data['work_orders.change_status'] == true;
          final reassign = data['work_orders.reassign'] == true;
          final managePendingRequests =
              data['work_orders.manage_pending_requests'] == true ||
              data['work_orders.handle_status_changes'] == true ||
              data['work_orders.approve_pause'] == true ||
              data['work_orders.approve_completion'] == true;
          final deleteObservation =
              data['work_orders.delete_observation'] == true;

          workOrders = WorkOrdersPermissionEntity(
            readScope: readScope,
            create: create,
            updateScope: updateScope,
            delete: delete,
            changeStatus: changeStatus,
            reassign: reassign,
            managePendingRequests: managePendingRequests,
            deleteObservation: deleteObservation,
          );
        }
      } else if (data is List) {
        // Parse legacy JSON array format
        bool hasWorkOrderRead = false;
        bool hasWorkOrderUpdate = false;
        bool isSuperAdmin = false;

        for (final p in data) {
          final code = p.toString();
          if (code == '*') {
            isSuperAdmin = true;
            ResourceType.values.forEach(addAllActionsForResource);
          } else if (code.endsWith('.*') || code.endsWith(':*')) {
            final prefix = code.substring(0, code.length - 2);
            final resource = ResourceType.fromCode(prefix);
            if (resource != null) {
              addAllActionsForResource(resource);
              if (resource == ResourceType.workOrders) {
                hasWorkOrderRead = true;
                hasWorkOrderUpdate = true;
              }
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
                if (resource == ResourceType.workOrders) {
                  if (action == PermissionAction.read) hasWorkOrderRead = true;
                  if (action == PermissionAction.update) {
                    hasWorkOrderUpdate = true;
                  }
                } else {
                  grouped.putIfAbsent(resource, () => {}).add(action);
                }
              }
            }
          }
        }

        if (isSuperAdmin) {
          workOrders = const WorkOrdersPermissionEntity.defaultAdmin();
        } else {
          workOrders = WorkOrdersPermissionEntity(
            readScope: hasWorkOrderRead
                ? WorkOrderReadScope.all
                : WorkOrderReadScope.assigned,
            create: data.contains('work_orders.create'),
            updateScope: hasWorkOrderUpdate
                ? WorkOrderUpdateScope.all
                : (hasWorkOrderRead
                      ? WorkOrderUpdateScope.assigned
                      : WorkOrderUpdateScope.none),
            delete: data.contains('work_orders.delete'),
            changeStatus: hasWorkOrderRead || hasWorkOrderUpdate,
            reassign: false,
            managePendingRequests: false,
            deleteObservation: false,
          );
        }
      }
    }

    return (grouped, workOrders);
  }

  @override
  MapDynamic toJson() {
    final Map<String, dynamic> flat = {};

    permissions.forEach((resource, actions) {
      for (final action in actions) {
        flat['${resource.code}.${action.code}'] = true;
      }
    });

    flat['work_orders.read_scope'] = workOrders.readScope.code;
    flat['work_orders.create'] = workOrders.create;
    flat['work_orders.update_scope'] = workOrders.updateScope.code;
    flat['work_orders.delete'] = workOrders.delete;
    flat['work_orders.change_status'] = workOrders.changeStatus;
    flat['work_orders.reassign'] = workOrders.reassign;
    flat['work_orders.manage_pending_requests'] =
        workOrders.managePendingRequests;
    flat['work_orders.delete_observation'] = workOrders.deleteObservation;

    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'permissions': flat,
      'is_default': isDefault,
      'created_at': createdAt.toIsoUtcString(),
      'deleted_at': deletedAt?.toIsoUtcString(),
    };
  }

  @override
  PermissionGroupEntity toEntity() => PermissionGroupEntity(
    id: id,
    companyId: companyId,
    name: name,
    permissions: permissions,
    workOrders: workOrders,
    isDefault: isDefault,
    createdAt: createdAt,
    deletedAt: deletedAt,
  );
}
