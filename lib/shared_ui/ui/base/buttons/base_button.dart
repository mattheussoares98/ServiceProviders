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

part '_primary_button.dart';
part '_secondary_button.dart';
part '_text_button.dart';

enum _ButtonVariant { primary, secondary, text }

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
    this.elevation,
    this.padding,
  }) : _variant = _ButtonVariant.primary,
       iconAlignment = IconAlignment.start;

  const BaseButton.secondary({
    super.key,
    required this.onTap,
    required this.text,
    this.textType = TextType.bodyLarge,
    this.textFontWeight = FontWeight.w500,
    this.foregroundColor,
    this.height,
    this.width,
    this.color,
    this.isLoading = false,
    this.expandWidth = false,
    this.platformIcon,
    this.permission,
    this.elevation,
    this.padding,
  }) : _variant = _ButtonVariant.secondary,
       iconAlignment = IconAlignment.start;

  const BaseButton.text({
    super.key,
    required FutureOr<void> Function()? onPressed,
    required this.text,
    this.textType,
    this.textFontWeight,
    Color? textColor,
    this.color,
    this.height,
    this.width,
    this.isLoading = false,
    this.expandWidth = false,
    this.platformIcon,
    this.permission,
    this.elevation,
    this.padding,
    this.iconAlignment = IconAlignment.start,
  }) : _variant = _ButtonVariant.text,
       onTap = onPressed,
       foregroundColor = textColor;

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
  final double? elevation;
  final EdgeInsets? padding;
  final IconAlignment? iconAlignment;
  final _ButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    if (permission != null) {
      if (!context.hasPermission(permission!)) {
        return const SizedBox.shrink();
      }
    }

    final tapCallback = (isLoading || onTap == null)
        ? null
        : () {
            FocusManager.instance.primaryFocus?.unfocus();
            onTap!();
          };

    final resolvedForegroundColor = switch (_variant) {
      _ButtonVariant.primary => foregroundColor ?? AppColors.white,
      _ButtonVariant.secondary =>
        color ?? foregroundColor ?? context.colorScheme.primary,
      _ButtonVariant.text => foregroundColor ?? color ?? AppColors.hightLight,
    };

    final effectiveForegroundColor =
        (_variant == _ButtonVariant.text && (isLoading || onTap == null))
        ? resolvedForegroundColor.withValues(alpha: 0.5)
        : resolvedForegroundColor;

    final resolvedFontWeight = switch (_variant) {
      _ButtonVariant.primary ||
      _ButtonVariant.secondary => textFontWeight ?? FontWeight.w500,
      _ButtonVariant.text => textFontWeight ?? FontWeight.w400,
    };

    final showStartIcon =
        platformIcon != null &&
        (iconAlignment == null || iconAlignment == IconAlignment.start);
    final showEndIcon =
        platformIcon != null && iconAlignment == IconAlignment.end;

    final textWidget = BaseText(
      text,
      textAlign: TextAlign.center,
      color: effectiveForegroundColor,
      textType: textType ?? TextType.bodyLarge,
      fontWeight: resolvedFontWeight,
    );

    final childWidget = isLoading
        ? LoadingCircle.small(effectiveForegroundColor)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showStartIcon) ...[
                Flexible(flex: (text.length / 3).ceil(), child: platformIcon!),
                gapW8,
              ],
              Flexible(flex: text.length, child: textWidget),
              if (showEndIcon) ...[
                gapW8,
                Flexible(flex: (text.length / 3).ceil(), child: platformIcon!),
              ],
            ],
          );

    final content = switch (_variant) {
      _ButtonVariant.primary => _PrimaryButtonWrapper(
        color: color,
        elevation: elevation,
        padding: padding,
        onTap: tapCallback,
        child: childWidget,
      ),
      _ButtonVariant.secondary => _SecondaryButtonWrapper(
        color: color,
        elevation: elevation,
        padding: padding,
        onTap: tapCallback,
        child: childWidget,
      ),
      _ButtonVariant.text => _TextButtonWrapper(
        color: color,
        elevation: elevation,
        padding: padding,
        onTap: tapCallback,
        child: childWidget,
      ),
    };

    if (_variant == _ButtonVariant.text &&
        !expandWidth &&
        width == null &&
        height == null) {
      return content;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height ?? (_variant == _ButtonVariant.text ? 0 : 50),
        minWidth: expandWidth ? double.infinity : (width ?? 0),
        maxWidth: expandWidth ? double.infinity : (width ?? double.infinity),
      ),
      child: content,
    );
  }
}
