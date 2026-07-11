import 'package:flutter/cupertino.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_rich_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

enum TitleAndSubtitleType {
  percentage('%'),
  money(r'R$');

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
  });
  final BaseText title;
  final BaseText? subtitle;
  final TitleAndSubtitleType? type;
  final bool useColon;

  @override
  Widget build(BuildContext context) {
    return BaseRichText(
      texts: [
        title,
        if (useColon) title.copyWith(text: ': '),
        ?subtitle,
        if (type != null) BaseText.caption(type!.label),
      ],
    );
  }
}
