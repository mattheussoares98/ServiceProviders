part of '../create_provider_work_order_page.dart';

class _ProviderAreaDropdown extends StatelessWidget {
  const _ProviderAreaDropdown({
    required this.locationId,
    required this.selectedId,
    required this.onChanged,
    required this.companyId,
  });

  final String? locationId;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final String? companyId;

  @override
  Widget build(BuildContext context) {
    if (locationId == null) return const SizedBox.shrink();

    return BaseStateView<LocationsCubit, LocationsState, List<AreaEntity>>(
      onRetry: () => companyId != null
          ? context.read<LocationsCubit>().loadProviderRegistry(companyId!)
          : null,
      dataSelector: (state) => state.areasByLocation[locationId] ?? const [],
      builder: (context, areas) {
        if (areas.isEmpty) return const SizedBox.shrink();

        return BaseDropDown<String>(
          key: const ValueKey('ProviderArea'),
          showLabelAtTopLeft: true,
          label: 'Área'.hardcoded,
          selectedItem: selectedId,
          onClear: () => onChanged(null),
          items: areas
              .map((e) => DropdownMenuItem(value: e.id, child: BaseText(e.name)))
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}
