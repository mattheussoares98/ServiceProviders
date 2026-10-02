part of '../create_update_asset_page.dart';

class _CustomerDropdown extends StatelessWidget {
  const _CustomerDropdown({
    required this.selectedId,
    required this.onChanged,
  });

  final String? selectedId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final customers = context.select(
      (CustomersCubit cubit) => cubit.state.customers
          .where((c) => c.isActive || c.id == selectedId)
          .toList(),
    );
    final items = customers.map(
      (e) => DropdownMenuItem(value: e.id, child: BaseText(e.name)),
    );

    return BaseDropDown<String>(
      key: const ValueKey('AssetCustomer'),
      showLabelAtTopLeft: true,
      label: 'Cliente (opcional)'.hardcoded,
      selectedItem: selectedId,
      hint: customers.isEmpty
          ? BaseText('Sem clientes cadastrados'.hardcoded)
          : BaseText('Ativo geral / Reutilizável'.hardcoded),
      items: items.toList(),
      onChanged: onChanged != null ? (val) => onChanged!(val) : null,
      onClear: selectedId != null && onChanged != null
          ? () => onChanged!(null)
          : null,
    );
  }
}
