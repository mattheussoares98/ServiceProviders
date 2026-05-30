import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseTextButton extends StatelessWidget {
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
  });
  final void Function() onPressed;
  final String text;
  final Color? textColor;
  final TextType? textType;
  final FontWeight? textFontWeight;
  final Color? color;
  final EdgeInsets? padding;
  final VisualDensity? visualDensity;
  final double? elevation;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final appliedTextType = textType ?? TextType.bodyLarge;
    final appliedFontWeight = textFontWeight ?? FontWeight.w400;
    final baseColor = textColor ?? color ?? AppColors.hightLight;
    final finalColor = isLoading ? baseColor.withValues(alpha: 0.5) : baseColor;

    final baseText = BaseText(
      text,
      color: finalColor,
      textType: appliedTextType,
      fontWeight: appliedFontWeight,
    );
    if (context.isCupertino) {
      return CupertinoButton(
        onPressed: isLoading ? null : onPressed,
        padding: padding ?? EdgeInsets.zero,
        minimumSize: Size.zero,
        child: baseText,
      );
    }

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: padding,
        visualDensity: visualDensity,
        elevation: elevation,
      ),
      child: baseText,
    );
  }
}
