import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class StatusDropdown extends StatelessWidget {
  const StatusDropdown({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });
  final AssetStatus? selectedStatus;
  final ValueChanged<AssetStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return BaseDropDown<AssetStatus>(
      key: const ValueKey('Status'),
      label: 'Status *'.hardcoded,
      selectedItem: selectedStatus,
      showLabelAtTopLeft: true,
      items: AssetStatus.values.map((s) {
        return DropdownMenuItem<AssetStatus>(
          value: s,
          child: BaseText(s.label),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
