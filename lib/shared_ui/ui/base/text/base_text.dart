import 'package:flutter/material.dart';

part 'text_type.dart';

class BaseText extends StatelessWidget {
  const BaseText(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.color,
    this.textType = TextType.bodyMedium,
    this.fontWeight = FontWeight.normal,
    this.decoration,
    this.decorationColor,
    this.fontStyle,
  });

  factory BaseText.caption(
    String text, {
    TextAlign? textAlign,
    TextOverflow? overflow,
    Color? color,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    Color? decorationColor,
    FontStyle? fontStyle,
  }) => BaseText(
    text,
    textAlign: textAlign,
    overflow: overflow,
    color: color,
    fontStyle: fontStyle,
    textType: TextType.caption,
    fontWeight: fontWeight ?? FontWeight.w400,
    decoration: decoration,
    decorationColor: decorationColor,
  );

  factory BaseText.bodySmall(
    String text, {
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    Color? decorationColor,
    FontStyle? fontStyle,
  }) => BaseText(
    text,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    fontStyle: fontStyle,
    color: color,
    textType: TextType.bodySmall,
    fontWeight: fontWeight ?? FontWeight.w400,
    decoration: decoration,
    decorationColor: decorationColor,
  );

  factory BaseText.bodyLarge(
    String text, {
    TextAlign? textAlign,
    Color? color,
    FontWeight? fontWeight,
    TextOverflow? overflow,
    FontStyle? fontStyle,
  }) => BaseText(
    text,
    overflow: overflow,
    textAlign: textAlign,
    fontStyle: fontStyle,
    color: color,
    textType: TextType.bodyLarge,
    fontWeight: fontWeight ?? FontWeight.w400,
  );

  factory BaseText.title(
    String text, {
    TextAlign? textAlign,
    Color? color,
    int? maxLines,
  }) => BaseText(
    text,
    textAlign: textAlign,
    color: color,
    maxLines: maxLines,
    textType: TextType.titleSmall,
    fontWeight: FontWeight.w600,
  );

  factory BaseText.titleMedium(
    String text, {
    TextAlign? textAlign,
    Color? color,
    FontWeight? fontWeight,
  }) => BaseText(
    text,
    textAlign: textAlign,
    color: color,
    textType: TextType.titleMedium,
    fontWeight: fontWeight ?? FontWeight.w600,
  );

  factory BaseText.bodyMedium(
    String text, {
    TextAlign? textAlign,
    Color? color,
    FontWeight? fontWeight,
  }) => BaseText(
    text,
    textAlign: textAlign,
    color: color,
    fontWeight: fontWeight ?? FontWeight.w400,
  );

  factory BaseText.headline(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextOverflow? overflow,
    int? maxLines,
  }) => BaseText(
    text,
    color: color,
    textType: TextType.headline,
    fontWeight: fontWeight ?? FontWeight.w600,
    overflow: overflow,
    maxLines: maxLines,
  );

  factory BaseText.headlineLarge(String text, {Color? color}) => BaseText(
    text,
    color: color,
    textType: TextType.headlineLarge,
    fontWeight: FontWeight.w600,
  );
  factory BaseText.error(
    String text, {
    TextAlign? textAlign,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) => BaseText(
    text,
    textAlign: textAlign ?? TextAlign.center,
    color: Colors.red,
    textType: TextType.titleMedium,
    fontWeight: fontWeight ?? FontWeight.w600,
    fontStyle: fontStyle,
  );

  BaseText copyWith({
    String? text,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    TextType? textType,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    Color? decorationColor,
    FontStyle? fontStyle,
  }) {
    return BaseText(
      text ?? this.text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      textType: textType ?? TextType.bodyMedium,
      fontWeight: fontWeight ?? FontWeight.normal,
      decoration: decoration,
      decorationColor: decorationColor,
      fontStyle: fontStyle,
    );
  }

  final String text;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final Color? color;
  final TextType textType;
  final FontWeight fontWeight;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final FontStyle? fontStyle;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: TextStyle(
        color: color,
        fontSize: textType.size,
        fontWeight: fontWeight,
        decoration: decoration,
        fontStyle: fontStyle,
        decorationColor: decorationColor,
      ),
    );
  }
}
