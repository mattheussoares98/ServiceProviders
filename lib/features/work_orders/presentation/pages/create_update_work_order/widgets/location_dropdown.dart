part of '../create_update_work_order_page.dart';

class _LocationDropdown extends StatelessWidget {
  const _LocationDropdown({
    required this.selectedId,
    required this.onChanged,
    this.isRequired = true,
  });
  final String? selectedId;
  final ValueChanged<String?>? onChanged;
  final bool isRequired;

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
      label: isRequired ? 'Local *'.hardcoded : 'Local'.hardcoded,
      selectedItem: selectedId,
      validator: isRequired
          ? (val) => val == null ? 'Selecione um local'.hardcoded : null
          : null,
      items: items.toList(),
      onClear: isRequired ? null : () => onChanged?.call(null),
      onChanged: onChanged,
    );
  }
}
