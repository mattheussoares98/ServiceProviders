part of '../create_provider_work_order_page.dart';

class _ProviderTypeDropdown extends StatelessWidget {
  const _ProviderTypeDropdown({
    required this.selected,
    required this.onChanged,
  });

  final WorkOrderType selected;
  final ValueChanged<WorkOrderType> onChanged;

  @override
  Widget build(BuildContext context) {
    return BaseDropDown<WorkOrderType>(
      key: const ValueKey('ProviderType'),
      showLabelAtTopLeft: true,
      label: 'Tipo *'.hardcoded,
      selectedItem: selected,
      items: WorkOrderType.values
          .map((e) => DropdownMenuItem(value: e, child: BaseText(e.label)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
