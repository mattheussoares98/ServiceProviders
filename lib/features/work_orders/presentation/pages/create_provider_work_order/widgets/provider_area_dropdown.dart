part of '../create_provider_work_order_page.dart';

class _ProviderAreaDropdown extends StatelessWidget {
  const _ProviderAreaDropdown({
    required this.locationId,
    required this.selectedId,
    required this.onChanged,
  });

  final String? locationId;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final areas = context.select<LocationsCubit, List<AreaEntity>>(
      (cubit) => cubit.state.areasByLocation[locationId] ?? const [],
    );

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
  }
}
