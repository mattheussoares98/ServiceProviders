import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParentAssetDropdown extends StatelessWidget {
  const ParentAssetDropdown({
    super.key,
    required this.onChanged,
    required this.selectedParentAssetId,
    required this.selectedAreaId,
  });
  final String? selectedParentAssetId;
  final ValueChanged<String?> onChanged;
  final String? selectedAreaId;

  @override
  Widget build(BuildContext context) {
    final allAssets = context.select<AssetsCubit, List<AssetEntity>>((cubit) {
      return cubit.state.assets
          .where((e) => e.areaId == selectedAreaId)
          .toList();
    });
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(value: '', child: BaseText('Nenhum'.hardcoded)),
      ...allAssets.map((e) {
        return DropdownMenuItem<String>(value: e.id, child: BaseText(e.name));
      }),
    ];

    return BaseDropDown<String>(
      //TODO fix it. Is not showing father options
      key: const ValueKey('ParentAsset'),
      label: 'Equipamento pai (opcional)'.hardcoded,
      selectedItem: selectedParentAssetId,
      items: items,
      onChanged: onChanged,
      showLabelAtTopLeft: true,
    );
  }
}
