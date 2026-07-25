import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_sub_action.dart';

sealed class ActionPermission extends Equatable {
  const ActionPermission();

  const factory ActionPermission.resource({
    required ResourceType resource,
    required PermissionAction action,
  }) = ResourceActionPermission;

  const factory ActionPermission.workOrderSubAction(
    WorkOrderSubAction subAction,
  ) = WorkOrderSubActionPermission;
}

final class ResourceActionPermission extends ActionPermission {
  const ResourceActionPermission({
    required this.resource,
    required this.action,
  });

  final ResourceType resource;
  final PermissionAction action;

  @override
  List<Object?> get props => [resource, action];
}

final class WorkOrderSubActionPermission extends ActionPermission {
  const WorkOrderSubActionPermission(this.subAction);

  final WorkOrderSubAction subAction;

  @override
  List<Object?> get props => [subAction];
}
