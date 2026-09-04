import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_criticality.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class CriticalityDropdown extends StatelessWidget {
  const CriticalityDropdown({
    super.key,
    required this.selectedCriticality,
    required this.onChanged,
  });
  final AssetCriticality selectedCriticality;
  final ValueChanged<AssetCriticality> onChanged;

  @override
  Widget build(BuildContext context) {
    return BaseDropDown<AssetCriticality>(
      key: const ValueKey('Criticality'),
      label: 'Criticidade *'.hardcoded,
      showLabelAtTopLeft: true,
      selectedItem: selectedCriticality,
      items: AssetCriticality.values.map((c) {
        return DropdownMenuItem<AssetCriticality>(
          value: c,
          child: BaseText(c.label),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
