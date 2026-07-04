import 'dart:async';

import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SecondaryButton extends HookWidget {
  const SecondaryButton({
    super.key,
    required this.onTap,
    required this.text,
    this.textType = TextType.bodyLarge,
    this.textFontWeight = FontWeight.w500,
    this.foregroundColor,
    this.height,
    this.width,
    this.color,
    this.loadableButton = false,
    this.elevation,
    this.expandWidth = false,
    this.permission,
    this.platformIcon,
  });
  final FutureOr<void> Function()? onTap;
  final String text;
  final TextType textType;
  final FontWeight textFontWeight;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final bool loadableButton;
  final Color? color;
  final double? elevation;
  final bool expandWidth;
  final ActionPermission? permission;
  final PlatformIcon? platformIcon;

  @override
  Widget build(BuildContext context) {
    if (permission != null) {
      if (!context.hasPermission(permission!)) {
        return const SizedBox.shrink();
      }
    }

    final activeColor = color ?? context.colorScheme.primary;
    final activeForegroundColor =
        foregroundColor ?? context.colorScheme.primary;

    final isLoading = useState(false);

    final tapCallback = onTap == null
        ? null
        : () async {
            FocusManager.instance.primaryFocus?.unfocus();
            final result = onTap!();
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
          };

    final childWidget = isLoading.value
        ? LoadingCircle.small(activeForegroundColor)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (platformIcon != null) ...[
                Flexible(flex: (text.length / 3).ceil(), child: platformIcon!),
                gapW8,
              ],
              Flexible(
                flex: text.length,
                child: BaseText(
                  text,
                  color: activeForegroundColor,
                  textType: textType,
                  fontWeight: textFontWeight,
                ),
              ),
            ],
          );

    if (context.isCupertino) {
      return SizedBox(
        height: height ?? 50,
        width: expandWidth ? double.maxFinite : width,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: activeColor, width: 1.5),
            borderRadius: const BorderRadius.all(Radius.circular(Sizes.p8)),
          ),
          child: CupertinoButton(
            onPressed: isLoading.value ? null : tapCallback,
            padding: EdgeInsets.zero,
            child: Center(child: childWidget),
          ),
        ),
      );
    }

    return SizedBox(
      height: height ?? 50,
      width: expandWidth ? double.maxFinite : width,
      child: OutlinedButton(
        onPressed: isLoading.value ? null : tapCallback,
        style: OutlinedButton.styleFrom(elevation: elevation).copyWith(
          side: WidgetStateProperty.all(
            BorderSide(color: activeColor, width: 1.5),
          ),
        ),
        child: childWidget,
      ),
    );
  }
}
