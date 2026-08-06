part of '../create_update_work_order_page.dart';

class _PriorityDropdown extends StatelessWidget {
  const _PriorityDropdown({
    required this.onChanged,
    required this.selectedPriority,
  });

  final ValueChanged<Priority> onChanged;
  final Priority? selectedPriority;

  @override
  Widget build(BuildContext context) {
    return BaseDropDown<Priority>(
      showLabelAtTopLeft: true,
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
