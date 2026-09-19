import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class PlanLocationSelectors extends StatelessWidget {
  const PlanLocationSelectors({
    super.key,
    required this.selectedLocationId,
    required this.selectedAreaId,
    required this.selectedAssetId,
    required this.onLocationChanged,
    required this.onAreaChanged,
    required this.onAssetChanged,
  });

  final String? selectedLocationId;
  final String? selectedAreaId;
  final String? selectedAssetId;
  final ValueChanged<String?> onLocationChanged;
  final ValueChanged<String?> onAreaChanged;
  final ValueChanged<String?> onAssetChanged;

  @override
  Widget build(BuildContext context) {
    final locations = context.select(
      (LocationsCubit cubit) => cubit.state.locations,
    );
    final filteredAreas = context.select<LocationsCubit, List<AreaEntity>>((
      cubit,
    ) {
      return cubit.state.areasByLocation[selectedLocationId] ?? [];
    });
    final areasIds = filteredAreas.map((e) => e.id).toSet();
    final assets = context.select((AssetsCubit cubit) {
      return cubit.state.assets.where((asset) {
        if (selectedAreaId != null) {
          return asset.areaId == selectedAreaId;
        }
        if (selectedLocationId != null) {
          return areasIds.contains(asset.areaId);
        }
        return true;
      }).toList();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BaseDropDown<String>(
          key: const ValueKey('PlanLocation'),
          showLabelAtTopLeft: true,
          label: 'Local'.hardcoded,
          hint: BaseText('Selecione o local'.hardcoded),
          selectedItem: selectedLocationId,
          items: locations
              .map(
                (l) => DropdownMenuItem(value: l.id, child: BaseText(l.name)),
              )
              .toList(),
          onClear: () {
            onLocationChanged(null);
            onAreaChanged(null);
            onAssetChanged(null);
          },
          onChanged: (val) {
            onLocationChanged(val);
            onAreaChanged(null);
            onAssetChanged(null);
          },
        ),
        gapH16,
        BaseDropDown<String>(
          key: const ValueKey('PlanArea'),
          showLabelAtTopLeft: selectedAreaId != null,
          label: 'Área'.hardcoded,
          hint: selectedLocationId == null
              ? BaseText('Selecione primeiro o local'.hardcoded)
              : (filteredAreas.isEmpty
                    ? BaseText('Sem áreas cadastradas'.hardcoded)
                    : BaseText('Selecione a área'.hardcoded)),
          selectedItem: selectedAreaId,
          items: filteredAreas
              .map(
                (a) => DropdownMenuItem(value: a.id, child: BaseText(a.name)),
              )
              .toList(),
          onClear: () {
            onAreaChanged(null);
            onAssetChanged(null);
          },
          onChanged: selectedLocationId == null
              ? null
              : (val) {
                  onAreaChanged(val);
                  onAssetChanged(null);
                },
        ),
        gapH16,
        BaseDropDown<String>(
          key: const ValueKey('PlanAsset'),
          showLabelAtTopLeft: selectedAssetId != null,
          label: 'Ativo'.hardcoded,
          hint: BaseText('Selecione o ativo'.hardcoded),
          selectedItem: selectedAssetId,
          items: assets
              .map(
                (a) => DropdownMenuItem(value: a.id, child: BaseText(a.name)),
              )
              .toList(),
          onClear: () => onAssetChanged(null),
          onChanged: onAssetChanged,
        ),
      ],
    );
  }
}
