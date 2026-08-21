part of '../create_provider_work_order_page.dart';

class _ProviderLocationDropdown extends StatelessWidget {
  const _ProviderLocationDropdown({
    required this.selectedId,
    required this.onChanged,
    required this.companyId,
  });

  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final String? companyId;

  @override
  Widget build(BuildContext context) {
    return BaseStateView<LocationsCubit, LocationsState, List<LocationEntity>>(
      onRetry: () => companyId != null
          ? context.read<LocationsCubit>().loadProviderRegistry(companyId!)
          : null,
      dataSelector: (state) => state.locations,
      builder: (context, locations) {
        final items = locations
            .map((e) => DropdownMenuItem(value: e.id, child: BaseText(e.name)))
            .toList();

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
      },
    );
  }
}
