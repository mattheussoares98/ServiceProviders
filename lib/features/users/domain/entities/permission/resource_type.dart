enum ResourceType {
  attachments('attachments', 'Anexos'),
  assets('assets', 'Ativos'),
  categories('categories', 'Categorias'),
  // checklists('checklists', 'Checklists'),
  locations('locations', 'Locais'),
  workOrders('work_orders', 'Ordens de serviço'),
  // maintenancePlans('maintenance_plans', 'Planos de manutenção'),
  // reports('reports', 'Relatórios'),
  users('users', 'Usuários'),
  serviceProviders('service_providers', 'Prestadores de serviço'),
  sectors('sectors', 'Setores');

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
