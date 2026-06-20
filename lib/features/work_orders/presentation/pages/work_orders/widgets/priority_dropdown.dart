import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/priority.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/material.dart';

class PriorityDropdown extends StatelessWidget {
  const PriorityDropdown({
    super.key,
    required this.onChanged,
    required this.selectedPriority,
  });

  final ValueChanged<Priority> onChanged;
  final Priority? selectedPriority;

  @override
  Widget build(BuildContext context) {
    return BaseDropDown<Priority>(
      key: const ValueKey('Priority'),
      label: 'Prioridade *'.hardcoded,
      selectedItem: selectedPriority,
      items: Priority.values.map((p) {
        return DropdownMenuItem<Priority>(value: p, child: BaseText(p.label));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
