enum ResourceType {
  assets('assets'),
  attachments('attachments'),
  categories('categories'),
  // checklists('checklists'),
  locations('locations'),
  // reports('reports'),
  // maintenancePlans('maintenance_plans'),
  accessLogs('access_logs'),
  sectors('sectors'),
  serviceProviders('service_providers'),
  slaPolicies('sla_policies'),
  users('users'),
  workOrders('work_orders');

  const ResourceType(this.code);
  final String code;

  static ResourceType? fromCode(String code) {
    for (final val in ResourceType.values) {
      if (val.code == code) return val;
    }
    return null;
  }
}
