import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class BaseRemovableChip extends StatelessWidget {
  const BaseRemovableChip({
    super.key,
    required this.label,
    required this.onRemove,
    this.iconSize = 14,
  });

  final String label;
  final VoidCallback onRemove;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: BaseText(label),
      deleteIcon: PlatformIcon(
        materialIcon: Icons.close,
        cupertinoIcon: CupertinoIcons.clear,
        color: Colors.red,
        size: iconSize,
      ),
      onDeleted: onRemove,
    );
  }
}
