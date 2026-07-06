import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class WorkOrderTypeDropdown extends StatelessWidget {
  const WorkOrderTypeDropdown({
    super.key,
    this.selectedType,
    required this.onChanged,
  });

  final WorkOrderType? selectedType;
  final ValueChanged<WorkOrderType> onChanged;

  @override
  Widget build(BuildContext context) {
    return BaseDropDown<WorkOrderType>(
      key: const ValueKey('Type'),
      label: 'Tipo *'.hardcoded,
      selectedItem: selectedType,
      showLabelAtTopLeft: true,
      items: WorkOrderType.values.map((t) {
        return DropdownMenuItem<WorkOrderType>(
          value: t,
          child: BaseText(t.label),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
