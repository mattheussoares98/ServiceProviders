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

class BaseTextButton extends HookWidget {
  const BaseTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.textColor,
    this.textType,
    this.textFontWeight,
    this.color,
    this.padding,
    this.visualDensity,
    this.elevation,
    this.isLoading = false,
    this.platformIcon,
  });
  final FutureOr<void> Function()? onPressed;
  final String text;
  final Color? textColor;
  final TextType? textType;
  final FontWeight? textFontWeight;
  final Color? color;
  final EdgeInsets? padding;
  final VisualDensity? visualDensity;
  final double? elevation;
  final bool isLoading;
  final PlatformIcon? platformIcon;

  @override
  Widget build(BuildContext context) {
    final appliedTextType = textType ?? TextType.bodyLarge;
    final appliedFontWeight = textFontWeight ?? FontWeight.w400;
    final baseColor = textColor ?? color ?? AppColors.hightLight;
    final finalColor = isLoading ? baseColor.withValues(alpha: 0.5) : baseColor;

    Widget childWidget = isLoading
        ? LoadingCircle.small(baseColor)
        : Flexible(
            child: BaseText(
              text,
              color: finalColor,
              textType: appliedTextType,
              fontWeight: appliedFontWeight,
            ),
          );

    if (platformIcon != null && !isLoading) {
      childWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [platformIcon!, gapW8, childWidget],
      );
    }

    void appliedOnTap() {
      FocusManager.instance.primaryFocus?.unfocus();
      onPressed?.call();
    }

    if (context.isCupertino) {
      return CupertinoButton(
        onPressed: isLoading ? null : appliedOnTap,
        padding: padding ?? EdgeInsets.zero,
        minimumSize: Size.zero,
        child: childWidget,
      );
    }

    return TextButton(
      onPressed: isLoading ? null : appliedOnTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: padding,
        visualDensity: visualDensity,
        elevation: elevation,
      ),
      child: childWidget,
    );
  }
}
