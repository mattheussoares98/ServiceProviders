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

  final List<Widget> texts;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: texts.map<InlineSpan>((widget) {
          if (widget is BaseText) {
            return TextSpan(
              text: widget.text,
              style: TextStyle(
                color: widget.color ?? color,
                fontSize: widget.textType.size,
                fontWeight: widget.fontWeight,
                decoration: widget.decoration,
                fontStyle: widget.fontStyle,
                decorationColor: widget.decorationColor,
              ),
            );
          } else if (widget is InlineSpan) {
            return widget as InlineSpan;
          }
          return WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: widget,
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
