part of '../create_provider_work_order_page.dart';

class _ProviderPriorityDropdown extends StatelessWidget {
  const _ProviderPriorityDropdown({
    required this.selected,
    required this.onChanged,
  });

  final Priority selected;
  final ValueChanged<Priority> onChanged;

  @override
  Widget build(BuildContext context) {
    return BaseDropDown<Priority>(
      key: const ValueKey('ProviderPriority'),
      showLabelAtTopLeft: true,
      label: 'Prioridade *'.hardcoded,
      selectedItem: selected,
      items: Priority.values
          .map((e) => DropdownMenuItem(value: e, child: BaseText(e.label)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
