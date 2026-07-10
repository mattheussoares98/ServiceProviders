import 'package:equatable/equatable.dart';

enum ResourceType {
  attachments('attachments', 'Anexos'),
  assets('assets', 'Ativos'),
  categories('categories', 'Categorias'),
  checklists('checklists', 'Checklists'),
  locations('locations', 'Locais'),
  workOrders('work_orders', 'Ordens de serviço'),
  maintenancePlans('maintenance_plans', 'Planos de manutenção'),
  reports('reports', 'Relatórios'),
  users('users', 'Usuários');

  const ResourceType(this.code, this.label);
  final String code;
  final String label;

  static ResourceType? fromCode(String code) {
    for (final val in ResourceType.values) {
      if (val.code == code) return val;
    }
    return null;
  }
}

enum PermissionAction {
  create('create', 'Criar'),
  read('read', 'Pesquisar'),
  update('update', 'Alterar'),
  delete('delete', 'Excluir');

  const PermissionAction(this.code, this.label);
  final String code;
  final String label;

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
  bool get canRead => actions.contains(PermissionAction.read);
  bool get canUpdate => actions.contains(PermissionAction.update);
  bool get canDelete => actions.contains(PermissionAction.delete);

  @override
  List<Object?> get props => [resource, actions];
}

class ActionPermission extends Equatable {
  const ActionPermission({required this.resource, required this.action});

  final ResourceType resource;
  final PermissionAction action;

  @override
  List<Object?> get props => [resource, action];
}
