part of '../create_update_work_order_page.dart';

class _AreaDropdown extends StatelessWidget {
  const _AreaDropdown({
    required this.selectedLocationId,
    required this.selectedAreaId,
    required this.onChanged,
  });
  final String? selectedAreaId;
  final String? selectedLocationId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final filteredAreas = context.select<LocationsCubit, List<AreaEntity>>((
      cubit,
    ) {
      return cubit.state.areasByLocation[selectedLocationId] ?? [];
    });
    final areasItems = filteredAreas
        .map(
          (e) => DropdownMenuItem<String>(value: e.id, child: BaseText(e.name)),
        )
        .toList();

    return BaseDropDown<String>(
      key: const ValueKey('Area'),
      label: 'Área'.hardcoded,
      selectedItem: selectedAreaId,
      hint: selectedLocationId == null
          ? BaseText('Selecione primeiro o local'.hardcoded)
          : (filteredAreas.isEmpty
                ? BaseText('Sem áreas cadastradas'.hardcoded)
                : BaseText('Selecione a área'.hardcoded)),
      items: areasItems,
      onChanged: onChanged,
      showLabelAtTopLeft: selectedAreaId?.isNotEmpty ?? false,
    );
  }
}
