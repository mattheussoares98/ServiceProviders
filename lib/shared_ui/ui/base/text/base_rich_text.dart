import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class BaseRichText extends StatelessWidget {
  const BaseRichText({
    required this.texts,
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.color,
  });

  final List<BaseText> texts;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: texts.map((baseText) {
          return TextSpan(
            text: baseText.text,
            style: TextStyle(
              color: baseText.color ?? color,
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
