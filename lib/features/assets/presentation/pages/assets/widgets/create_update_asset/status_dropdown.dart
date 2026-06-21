import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_status.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/material.dart';

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
