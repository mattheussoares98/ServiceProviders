import 'dart:async';

import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PrimaryButton extends HookWidget {
  const PrimaryButton({
    super.key,
    required this.onTap,
    required this.text,
    this.textType,
    this.textFontWeight,
    this.foregroundColor = AppColors.white,
    this.height,
    this.width,
    this.color,
    this.isLoading = false,
    this.expandWidth = false,
    this.platformIcon,
  });
  final FutureOr<void> Function()? onTap;
  final String text;
  final TextType? textType;
  final FontWeight? textFontWeight;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final bool isLoading;
  final Color? color;
  final bool expandWidth;
  final PlatformIcon? platformIcon;

  @override
  Widget build(BuildContext context) {
    final localLoading = useState(false);
    final effectiveLoading = isLoading || localLoading.value;

    final tapCallback = onTap == null
        ? null
        : () async {
            final result = onTap!();
            if (result is Future) {
              localLoading.value = true;
              try {
                await result;
              } finally {
                if (context.mounted) {
                  localLoading.value = false;
                }
              }
            }
          };

    final effectiveForegroundColor = foregroundColor ?? AppColors.white;
    Widget childWidget = effectiveLoading
        ? LoadingCircle.small(effectiveForegroundColor)
        : BaseText(
            text,
            color: foregroundColor,
            textType: textType ?? TextType.bodyLarge,
            fontWeight: textFontWeight ?? FontWeight.w500,
          );

    if (platformIcon != null && !effectiveLoading) {
      childWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [platformIcon!, gapW8, childWidget],
      );
    }

    return SizedBox(
      height: height ?? 50,
      width: expandWidth ? double.maxFinite : width,
      child: context.isCupertino
          ? CupertinoButton(
              onPressed: effectiveLoading ? null : tapCallback,
              color: color ?? AppColors.primary,
              disabledColor: color ?? AppColors.primary,
              padding: EdgeInsets.zero,
              borderRadius: const BorderRadius.all(Radius.circular(Sizes.p8)),
              child: Center(child: childWidget),
            )
          : ElevatedButton(
              onPressed: effectiveLoading ? null : tapCallback,
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: childWidget,
            ),
    );
  }
}
