import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class ParentAssetDropdown extends StatelessWidget {
  const ParentAssetDropdown({
    super.key,
    required this.onChanged,
    required this.selectedParentAssetId,
    required this.selectedAreaId,
    required this.currentAssetId,
  });
  final String? selectedParentAssetId;
  final ValueChanged<String?> onChanged;
  final String? selectedAreaId;
  final String? currentAssetId;

  @override
  Widget build(BuildContext context) {
    final allAssets = context.select<AssetsCubit, List<AssetEntity>>((cubit) {
      return cubit.state.assets
          .where((e) => e.areaId == selectedAreaId && e.id != currentAssetId)
          .toList();
    });
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(value: '', child: BaseText('Nenhum'.hardcoded)),
      ...allAssets.map((e) {
        return DropdownMenuItem<String>(value: e.id, child: BaseText(e.name));
      }),
    ];

    return BaseDropDown<String>(
      key: const ValueKey('ParentAsset'),
      label: 'Equipamento pai (opcional)'.hardcoded,
      selectedItem: selectedParentAssetId,
      items: items,
      onChanged: onChanged,
      showLabelAtTopLeft: true,
    );
  }
}
