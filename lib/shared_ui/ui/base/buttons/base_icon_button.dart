import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class BaseIconButton extends StatelessWidget {
  const BaseIconButton({
    super.key,
    required this.onPressed,
    required this.platformIcon,
    this.padding,
    this.targetSize,
    this.excludeFromFocus = false,
    this.isLoading = false,
    this.permission,
  });
  final FutureOr<void>? Function()? onPressed;
  final PlatformIcon platformIcon;
  final EdgeInsets? padding;
  final double? targetSize;
  final bool excludeFromFocus;
  final bool isLoading;
  final ActionPermission? permission;

  @override
  Widget build(BuildContext context) {
    if (permission != null) {
      if (!context.hasPermission(permission!)) {
        return const SizedBox.shrink();
      }
    }

    FutureOr<void>? tapCallback() {
      FocusManager.instance.primaryFocus?.unfocus();
      onPressed?.call();
    }

    final iconWidget = isLoading
        ? LoadingCircle.small(platformIcon.color)
        : platformIcon.copyWith(
            color: onPressed == null ? context.theme.disabledColor : null,
          );

    Widget child;

    if (context.isCupertino) {
      child = CupertinoButton(
        onPressed: isLoading || onPressed == null ? null : tapCallback,
        padding: padding ?? EdgeInsets.zero,
        child: iconWidget,
      );
    } else {
      child = IconButton(
        onPressed: isLoading || onPressed == null ? null : tapCallback,
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
