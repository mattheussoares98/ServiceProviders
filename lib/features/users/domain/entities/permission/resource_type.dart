enum ResourceType {
  assets('assets', 'Ativos'),
  attachments('attachments', 'Anexos'),
  categories('categories', 'Categorias'),
  // checklists('checklists', 'Checklists'),
  locations('locations', 'Locais'),
  // reports('reports', 'Relatórios'),
  // maintenancePlans('maintenance_plans', 'Planos de manutenção'),
  sectors('sectors', 'Setores'),
  serviceProviders('service_providers', 'Prestadores de serviço'),
  slaPolicies('sla_policies', 'Políticas de SLA'),
  users('users', 'Usuários'),
  workOrders('work_orders', 'Ordens de serviço');

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
