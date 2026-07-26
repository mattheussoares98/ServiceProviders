import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class BaseCheckbox extends StatelessWidget {
  const BaseCheckbox({
    super.key,
    this.scale = 1.5,
    required this.value,
    this.onChanged,
    this.title,
  });
  final double? scale;
  final bool value;
  final void Function(bool?)? onChanged;
  final String? title;

  @override
  Widget build(BuildContext context) {
    Widget child = Transform.scale(
      scale: scale,
      child: context.isCupertino
          ? CupertinoCheckbox(
              value: value,
              activeColor: context.colorScheme.primary,
              onChanged: onChanged,
            )
          : Checkbox(
              value: value,
              onChanged: onChanged,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
    );

    if (title != null) {
      final textColor = value
          ? context.colorScheme.primary
          : context.colorScheme.onSurface;
      child = GestureDetector(
        onTap: onChanged != null ? () => onChanged!(!value) : null,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            gapW12,
            BaseText(title!, color: textColor, fontWeight: FontWeight.w500),
          ],
        ),
      );
    }

    return child;
  }
}
