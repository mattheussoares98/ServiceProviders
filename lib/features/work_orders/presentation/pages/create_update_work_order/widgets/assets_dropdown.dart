import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class AssetsDropdown extends StatelessWidget {
  const AssetsDropdown({
    super.key,
    required this.selectedAssetId,
    required this.selectedLocationId,
    required this.onChanged,
  });
  final String? selectedAssetId;
  final String? selectedLocationId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final areasIds = context
        .select<LocationsCubit, List<AreaEntity>?>((cubit) {
          return cubit.state.areasByLocation[selectedLocationId];
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
      onChanged: onChanged,
    );
  }
}
