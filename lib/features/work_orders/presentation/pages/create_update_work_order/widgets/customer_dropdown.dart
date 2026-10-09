part of '../create_update_work_order_page.dart';

class _CustomerDropdown extends StatelessWidget {
  const _CustomerDropdown({
    required this.selectedId,
    required this.onChanged,
    this.isRequired = true,
  });

  final String? selectedId;
  final ValueChanged<String?>? onChanged;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final customers = context.select(
      (CustomersCubit cubit) =>
          cubit.state.customers.where((c) => c.isActive).toList(),
    );
    final items = customers.map(
      (e) => DropdownMenuItem(value: e.id, child: BaseText(e.name)),
    );

    return BaseDropDown<String>(
      key: const ValueKey('Customer'),
      showLabelAtTopLeft: true,
      label: isRequired ? 'Cliente *'.hardcoded : 'Cliente'.hardcoded,
      selectedItem: selectedId,
      hint: customers.isEmpty
          ? BaseText('Sem clientes cadastrados'.hardcoded)
          : null,
      validator: isRequired
          ? (val) => val == null ? 'Selecione um cliente'.hardcoded : null
          : null,
      items: items.toList(),
      onClear: isRequired ? null : () => onChanged?.call(null),
      onChanged: onChanged,
    );
  }
}
