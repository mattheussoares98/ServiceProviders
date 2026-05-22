import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseIconButton extends StatelessWidget {
  const BaseIconButton({
    super.key,
    required this.onPressed,
    required this.platformIcon,
    this.splashRadius,
    this.padding,
    this.boxConstraints,
    this.visualDensity,
    this.targetSize,
    this.disableSplash = false,
    this.excludeFromFocus = false,
  });
  final void Function() onPressed;
  final PlatformIcon platformIcon;
  final double? splashRadius;
  final EdgeInsets? padding;
  final BoxConstraints? boxConstraints;
  final VisualDensity? visualDensity;
  final double? targetSize;
  final bool disableSplash;
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

      if (excludeFromFocus) {
        child = ExcludeFocus(child: child);
      }

      if (targetSize != null) {
        child = SizedBox(height: targetSize, width: targetSize, child: child);
      }
    } else {
      child = IconButton(
        splashRadius: splashRadius,
        onPressed: onPressed,
        padding: padding ?? EdgeInsets.zero,
        constraints: boxConstraints ?? const BoxConstraints(),
        visualDensity:
            visualDensity ?? const VisualDensity(horizontal: -4, vertical: -4),
        highlightColor: disableSplash ? Colors.transparent : null,
        icon: platformIcon,
      );

      if (disableSplash) {
        child = Theme(
          data: ThemeData(splashFactory: NoSplash.splashFactory),
          child: child,
        );
      }

      if (targetSize != null) {
        child = SizedBox(height: targetSize, width: targetSize, child: child);
      }
    }

    if (excludeFromFocus) {
      child = ExcludeFocus(child: child);
    }

    return child;
  }
}
