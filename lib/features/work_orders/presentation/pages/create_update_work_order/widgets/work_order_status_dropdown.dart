part of '../create_update_work_order_page.dart';

class _WorkOrderStatusDropdown extends StatelessWidget {
  const _WorkOrderStatusDropdown({
    required this.onChanged,
    required this.selectedStatus,
  });

  final ValueChanged<WorkOrderStatus> onChanged;
  final WorkOrderStatus? selectedStatus;

  @override
  Widget build(BuildContext context) {
    return BaseDropDown<WorkOrderStatus>(
      key: const ValueKey('WorkOrderStatus'),
      label: 'Status *'.hardcoded,
      selectedItem: selectedStatus,
      showLabelAtTopLeft: true,
      items:
          WorkOrderStatus.values.map((s) {
            return DropdownMenuItem<WorkOrderStatus>(
              value: s,
              child: BaseText(s.label),
            );
          }).toList()..removeWhere(
            (e) =>
                e.value == WorkOrderStatus.pendingConclusionApproval ||
                e.value == WorkOrderStatus.pendingPauseApproval,
          ),
      onChanged: onChanged,
    );
  }
}
