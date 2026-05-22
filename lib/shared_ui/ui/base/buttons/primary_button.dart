import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
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
  });
  final Future<void> Function() onTap;
  final String text;
  final TextType? textType;
  final FontWeight? textFontWeight;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final bool isLoading;
  final Color? color;
  final bool expandWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveForegroundColor = foregroundColor ?? AppColors.white;
    final childWidget = isLoading
        ? LoadingCircle.small(effectiveForegroundColor)
        : BaseText(
            text,
            color: foregroundColor,
            textType: textType ?? TextType.bodyLarge,
            fontWeight: textFontWeight ?? FontWeight.w500,
          );

    return SizedBox(
      height: height ?? 50,
      width: expandWidth ? double.maxFinite : width,
      child: context.isCupertino
          ? CupertinoButton(
              onPressed: isLoading ? null : onTap,
              color: color ?? AppColors.primary,
              disabledColor: color ?? AppColors.primary,
              padding: EdgeInsets.zero,
              borderRadius: const BorderRadius.all(Radius.circular(Sizes.p8)),
              child: Center(child: childWidget),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: childWidget,
            ),
    );
  }
}
