part of '../create_update_work_order_page.dart';

class _AssetsDropdown extends StatelessWidget {
  const _AssetsDropdown({
    required this.selectedAssetId,
    required this.selectedLocationId,
    required this.selectedAreaId,
    required this.onChanged,
    required this.applyAssociatedAreaId,
  });
  final String? selectedAssetId;
  final String? selectedLocationId;
  final String? selectedAreaId;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String?> applyAssociatedAreaId;

  @override
  Widget build(BuildContext context) {
    final areasIds = context
        .select<LocationsCubit, List<AreaEntity>?>((cubit) {
          final areas = cubit.state.areasByLocation[selectedLocationId];
          if (selectedAreaId == null) {
            return areas;
          } else {
            return [?areas?.firstWhereOrNull((e) => e.id == selectedAreaId)];
          }
        })
        ?.map((e) => e.id);
    final filteredAssets = context.select<AssetsCubit, List<AssetEntity>>((
      cubit,
    ) {
      return cubit.state.assets
          .where((asset) => areasIds?.contains(asset.areaId) == true)
          .toList();
    });
    final assetDropdownItems = filteredAssets.map((a) {
      return DropdownMenuItem<String>(value: a.id, child: BaseText(a.name));
    }).toList();

    return BaseDropDown<String>(
      key: const ValueKey('Asset'),
      showLabelAtTopLeft: true,
      label: 'Equipamento (opcional)'.hardcoded,
      selectedItem: selectedAssetId,
      hint: selectedLocationId == null
          ? BaseText('Selecione primeiro o local'.hardcoded)
          : (filteredAssets.isEmpty
                ? BaseText('Sem equipamentos cadastrados'.hardcoded)
                : null),
      items: selectedLocationId == null ? null : assetDropdownItems,
      onChanged: onChanged == null
          ? null
          : (value) {
              onChanged!.call(value);

              final respectiveAsset = filteredAssets.firstWhereOrNull(
                (e) => e.id == value,
              );
              applyAssociatedAreaId.call(respectiveAsset?.areaId);
            },
    );
  }
}
