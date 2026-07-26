import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class BaseButton extends StatelessWidget {
  const BaseButton({
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
    this.permission,
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
  final ActionPermission? permission;

  @override
  Widget build(BuildContext context) {
    if (permission != null) {
      if (!context.hasPermission(permission!)) {
        return const SizedBox.shrink();
      }
    }

    final tapCallback = onTap == null
        ? null
        : () {
            FocusManager.instance.primaryFocus?.unfocus();
            onTap!();
          };

    final effectiveForegroundColor = foregroundColor ?? AppColors.white;
    Widget childWidget = isLoading
        ? LoadingCircle.small(effectiveForegroundColor)
        : BaseText(
            text,
            color: foregroundColor,
            textType: textType ?? TextType.bodyLarge,
            fontWeight: textFontWeight ?? FontWeight.w500,
          );

    if (platformIcon != null && !isLoading) {
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
              onPressed: tapCallback,
              color: color ?? AppColors.primary,
              disabledColor: color ?? AppColors.primary,
              padding: EdgeInsets.zero,
              borderRadius: const BorderRadius.all(Radius.circular(Sizes.p8)),
              child: Center(child: childWidget),
            )
          : ElevatedButton(
              onPressed: tapCallback,
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: childWidget,
            ),
    );
  }
}
