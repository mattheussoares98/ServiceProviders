enum Permission {
  all('*'),
  workOrdersAll('work_orders.*'),
  workOrdersViewAssigned('work_orders.view_assigned'),
  workOrdersUpdateStatus('work_orders.update_status'),
  assetsAll('assets.*'),
  locationsAll('locations.*'),
  reportsView('reports.view'),
  attachmentsAll('attachments.*'),
  checklistsFill('checklists.fill');

  const Permission(this.code);
  final String code;

  static Permission? fromCode(String code) {
    for (final val in Permission.values) {
      if (val.code == code) return val;
    }
    return null;
  }
}
