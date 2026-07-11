import 'package:flutter/cupertino.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_rich_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

enum TitleAndSubtitleType {
  money(r'R$'),
  percentage('%');

  const TitleAndSubtitleType(this.label);
  final String label;
}

class TitleAndSubtitle extends StatelessWidget {
  const TitleAndSubtitle({
    super.key,
    required this.title,
    this.subtitle,
    this.type,
    this.useColon = true,
    this.messageIfSubtitleIsNull,
    this.titleColor,
    this.subtitleColor,
  });
  final String title;
  final String? subtitle;
  final String? messageIfSubtitleIsNull;
  final TitleAndSubtitleType? type;
  final bool useColon;
  final Color? titleColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final applyedTitle =
        (subtitle?.isEmpty ?? false) && messageIfSubtitleIsNull != null
        ? messageIfSubtitleIsNull
        : title;
    return BaseRichText(
      texts: [
        BaseText(applyedTitle!, color: titleColor),
        if (useColon && subtitle != null) const BaseText(': '),
        if (subtitle != null && subtitle!.isNotEmpty)
          BaseText.bodyLarge(
            subtitle!,
            color: subtitleColor,
            fontWeight: FontWeight.bold,
          ),
        if (type != null) BaseText.caption(type!.label),
      ],
    );
  }
}
