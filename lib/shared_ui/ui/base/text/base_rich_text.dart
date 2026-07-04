import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/material.dart';

class BaseRichText extends StatelessWidget {
  const BaseRichText({
    required this.texts,
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
  });

  final List<BaseText> texts;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: texts.map((baseText) {
          return TextSpan(
            text: baseText.text,
            style: TextStyle(
              color: baseText.color,
              fontSize: baseText.textType.size,
              fontWeight: baseText.fontWeight,
              decoration: baseText.decoration,
              fontStyle: baseText.fontStyle,
              decorationColor: baseText.decorationColor,
            ),
          );
        }).toList(),
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
    );
  }
}
