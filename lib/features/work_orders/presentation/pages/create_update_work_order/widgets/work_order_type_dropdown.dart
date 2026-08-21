part of '../create_update_work_order_page.dart';

class _WorkOrderTypeDropdown extends StatelessWidget {
  const _WorkOrderTypeDropdown({this.selectedType, required this.onChanged});

  final WorkOrderType? selectedType;
  final ValueChanged<WorkOrderType>? onChanged;

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
