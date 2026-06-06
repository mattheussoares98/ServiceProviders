enum WorkOrderChangeType {
  addTask('add_task'),
  addAttachment('add_attachment'),
  updateNotes('update_notes'),
  fillChecklist('fill_checklist');

  const WorkOrderChangeType(this.code);
  final String code;

  static WorkOrderChangeType fromCode(String code) {
    for (final val in WorkOrderChangeType.values) {
      if (val.code == code) return val;
    }
    return WorkOrderChangeType.updateNotes;
  }
}
