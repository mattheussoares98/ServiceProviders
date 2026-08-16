part of '../create_update_work_order_page.dart';

class _WorkOrderStatusDropdown extends StatelessWidget {
  const _WorkOrderStatusDropdown({
    required this.onChanged,
    required this.selectedStatus,
  });

  final ValueChanged<WorkOrderStatus>? onChanged;
  final WorkOrderStatus? selectedStatus;

  @override
  Widget build(BuildContext context) {
    final isPendingConclusion =
        selectedStatus == WorkOrderStatus.pendingConclusionApproval;

    final items = isPendingConclusion
        ? [
            DropdownMenuItem<WorkOrderStatus>(
              value: WorkOrderStatus.pendingConclusionApproval,
              child: BaseText(WorkOrderStatus.pendingConclusionApproval.label),
            ),
          ]
        : WorkOrderStatus.values
            .where((s) => s != WorkOrderStatus.pendingConclusionApproval)
            .map((s) {
              return DropdownMenuItem<WorkOrderStatus>(
                value: s,
                child: BaseText(s.label),
              );
            })
            .toList();

    return BaseDropDown<WorkOrderStatus>(
      key: const ValueKey('WorkOrderStatus'),
      label: 'Status *'.hardcoded,
      selectedItem: selectedStatus,
      showLabelAtTopLeft: true,
      adviceMessage: isPendingConclusion
          ? 'Ordem de serviço aguardando aprovação de conclusão. Não é possível alterar o status diretamente.'.hardcoded
          : null,
      items: items,
      onChanged: isPendingConclusion ? null : onChanged,
    );
  }
}
