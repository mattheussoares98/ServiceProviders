part of '../create_provider_work_order_page.dart';

class _ProviderLocationDropdown extends StatelessWidget {
  const _ProviderLocationDropdown({
    required this.selectedId,
    required this.onChanged,
  });

  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = context.select(
      (LocationsCubit cubit) => cubit.state.locations
          .map((e) => DropdownMenuItem(value: e.id, child: BaseText(e.name)))
          .toList(),
    );

    return BaseDropDown<String>(
      key: const ValueKey('ProviderLocation'),
      showLabelAtTopLeft: true,
      label: 'Local *'.hardcoded,
      selectedItem: selectedId,
      validator: (value) =>
          value == null ? 'Selecione um local'.hardcoded : null,
      items: items,
      onChanged: onChanged,
    );
  }
}
