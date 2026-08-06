part of '../create_update_work_order_page.dart';

class _LocationDropdown extends StatelessWidget {
  const _LocationDropdown({required this.selectedId, required this.onChanged});
  final String? selectedId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final items = context.select(
      (LocationsCubit cubit) => cubit.state.locations.map(
        (e) => DropdownMenuItem(value: e.id, child: BaseText(e.name)),
      ),
    );

    return BaseDropDown<String>(
      key: const ValueKey('Location'),
      showLabelAtTopLeft: true,
      label: 'Local *'.hardcoded,
      selectedItem: selectedId,
      validator: (val) => val == null ? 'Selecione um local'.hardcoded : null,
      items: items.toList(),
      onChanged: onChanged,
    );
  }
}
