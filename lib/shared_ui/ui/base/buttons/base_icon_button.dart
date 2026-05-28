import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseIconButton extends StatelessWidget {
  const BaseIconButton({
    super.key,
    required this.onPressed,
    required this.platformIcon,
    this.padding,
    this.targetSize,
    this.excludeFromFocus = false,
  });
  final void Function() onPressed;
  final PlatformIcon platformIcon;
  final EdgeInsets? padding;
  final double? targetSize;
  final bool excludeFromFocus;

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (context.isCupertino) {
      child = CupertinoButton(
        onPressed: onPressed,
        padding: padding ?? EdgeInsets.zero,
        child: platformIcon,
      );
    } else {
      child = IconButton(
        onPressed: onPressed,
        icon: platformIcon,
        padding: padding ?? EdgeInsets.zero,
      );
    }

    if (targetSize != null) {
      child = SizedBox(height: targetSize, width: targetSize, child: child);
    }

    if (excludeFromFocus) {
      child = ExcludeFocus(child: child);
    }

    return child;
  }
}
