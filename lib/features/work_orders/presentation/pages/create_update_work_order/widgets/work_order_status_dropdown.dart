import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_status.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/material.dart';

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
      items: WorkOrderStatus.values.map((s) {
        return DropdownMenuItem<WorkOrderStatus>(
          value: s,
          child: BaseText(s.label),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
