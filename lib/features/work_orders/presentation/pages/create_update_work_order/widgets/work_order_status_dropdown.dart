import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class WorkOrderStatusDropdown extends StatelessWidget {
  const WorkOrderStatusDropdown({
    super.key,
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
