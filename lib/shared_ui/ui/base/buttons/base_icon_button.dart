import 'dart:async';

import 'package:clean_architecture/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BaseIconButton extends HookWidget {
  const BaseIconButton({
    super.key,
    required this.onPressed,
    required this.platformIcon,
    this.padding,
    this.targetSize,
    this.excludeFromFocus = false,
  });
  final FutureOr<void>? Function() onPressed;
  final PlatformIcon platformIcon;
  final EdgeInsets? padding;
  final double? targetSize;
  final bool excludeFromFocus;

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    Future<void> tapCallback() async {
      final result = onPressed();
      if (result is Future) {
        isLoading.value = true;
        try {
          await result;
        } finally {
          if (context.mounted) {
            isLoading.value = false;
          }
        }
      }
    }

    final iconWidget = isLoading.value
        ? LoadingCircle.small(platformIcon.color)
        : platformIcon;

    Widget child;

    if (context.isCupertino) {
      child = CupertinoButton(
        onPressed: isLoading.value ? null : tapCallback,
        padding: padding ?? EdgeInsets.zero,
        child: iconWidget,
      );
    } else {
      child = IconButton(
        onPressed: isLoading.value ? null : tapCallback,
        icon: iconWidget,
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
