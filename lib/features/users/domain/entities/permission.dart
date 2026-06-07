import 'package:equatable/equatable.dart';

enum ResourceType {
  workOrders('work_orders'),
  assets('assets'),
  locations('locations'),
  reports('reports'),
  attachments('attachments'),
  checklists('checklists');

  const ResourceType(this.code);
  final String code;

  static ResourceType? fromCode(String code) {
    for (final val in ResourceType.values) {
      if (val.code == code) return val;
    }
    return null;
  }
}

enum PermissionAction {
  create('create'),
  read('read'),
  update('update'),
  delete('delete'),
  viewAssigned('view_assigned'),
  updateStatus('update_status'),
  fill('fill');

  const PermissionAction(this.code);
  final String code;

  static PermissionAction? fromCode(String code) {
    for (final val in PermissionAction.values) {
      if (val.code == code) return val;
    }
    return null;
  }
}

class ResourcePermissionEntity extends Equatable {
  const ResourcePermissionEntity({
    required this.resource,
    required this.actions,
  });

  final ResourceType resource;
  final Set<PermissionAction> actions;

  bool get canCreate => actions.contains(PermissionAction.create);
  bool get canRead =>
      actions.contains(PermissionAction.read) ||
      actions.contains(PermissionAction.viewAssigned);
  bool get canUpdate =>
      actions.contains(PermissionAction.update) ||
      actions.contains(PermissionAction.updateStatus);
  bool get canDelete => actions.contains(PermissionAction.delete);
  bool get canViewAssigned => actions.contains(PermissionAction.viewAssigned);
  bool get canUpdateStatus => actions.contains(PermissionAction.updateStatus);
  bool get canFill => actions.contains(PermissionAction.fill);

  @override
  List<Object?> get props => [resource, actions];
}
