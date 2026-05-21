import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DefaultSwitch extends StatelessWidget {
  const DefaultSwitch({
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
        return CupertinoSwitch(
          value: value,
          onChanged: onChanged,
        );
      }
      return Switch.adaptive(
        value: value,
        onChanged: onChanged,
      );
    }

    final theme = Theme.of(context);
    final textStyle = theme.textTheme.titleSmall;

    if (context.isCupertino) {
      return CupertinoListTile(
        title: Text(title!, style: textStyle),
        padding: EdgeInsets.zero,
        trailing: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
        ),
      );
    } else {
      return SwitchListTile.adaptive(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(title!, style: textStyle),
        value: value,
        onChanged: onChanged,
      );
    }
  }
}
