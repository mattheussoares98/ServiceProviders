import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class ValidatedBadge extends StatelessWidget {
  const ValidatedBadge({
    super.key,
    required this.isValid,
    required this.platformIcon,
    this.isSelected = false,
    this.showSuccessBadge = true,
  });
  final bool isValid;
  final PlatformIcon platformIcon;
  final bool isSelected;
  final bool showSuccessBadge;

  @override
  Widget build(BuildContext context) {
    return Badge(
      offset: const Offset(8, -6),
      backgroundColor: Colors.transparent,
      label: isValid && !showSuccessBadge
          ? null
          : PlatformIcon(
              cupertinoIcon: isValid
                  ? CupertinoIcons.checkmark
                  : CupertinoIcons.clear,
              materialIcon: isValid ? Icons.check : Icons.close,
              color: isValid ? Colors.green : Colors.red,
              size: 17,
            ),
      child: PlatformIcon(
        cupertinoIcon: platformIcon.cupertinoIcon,
        materialIcon: platformIcon.materialIcon,
        size: platformIcon.size,
        color: isSelected
            ? context.theme.primaryColor
            : context.theme.disabledColor,
      ),
    );
  }
}
