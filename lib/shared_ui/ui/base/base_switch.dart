import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class BaseSwitch extends StatelessWidget {
  const BaseSwitch({
    super.key,
    this.title,
    required this.value,
    required this.onChanged,
  });

  final String? title;
  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    if (title == null) {
      if (context.isCupertino) {
        return CupertinoSwitch(value: value, onChanged: onChanged);
      }
      return Switch.adaptive(value: value, onChanged: onChanged);
    }

    if (context.isCupertino) {
      return CupertinoListTile(
        title: BaseText.title(title!, maxLines: 3),
        padding: EdgeInsets.zero,
        trailing: CupertinoSwitch(value: value, onChanged: onChanged),
      );
    } else {
      return SwitchListTile.adaptive(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: BaseText.title(title!, maxLines: 3),
        value: value,
        onChanged: onChanged,
      );
    }
  }
}
