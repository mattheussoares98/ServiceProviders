import 'package:equatable/equatable.dart';

enum ResourceType {
  workOrders('work_orders', 'Ordens de Serviço'),
  assets('assets', 'Ativos'),
  locations('locations', 'Locais'),
  reports('reports', 'Relatórios'),
  attachments('attachments', 'Anexos'),
  checklists('checklists', 'Checklists'),
  maintenancePlans('maintenance_plans', 'Planos de Manutenção'),
  users('users', 'Usuários'),
  categories('categories', 'Categorias');

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
  read('read', 'Ler'),
  update('update', 'Atualizar'),
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
