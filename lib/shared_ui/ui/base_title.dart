import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/material.dart';

class BaseTitle extends StatelessWidget {
  const BaseTitle({super.key, required this.title, this.color});
  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return BaseText.title(
      title,
      color: color ?? context.colorScheme.onSurface,
    );
  }
}
