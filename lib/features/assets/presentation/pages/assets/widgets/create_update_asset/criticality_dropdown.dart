import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_criticality.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/material.dart';

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
