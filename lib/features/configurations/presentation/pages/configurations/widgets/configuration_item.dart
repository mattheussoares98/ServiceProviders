import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ConfigurationItem extends StatelessWidget {
  const ConfigurationItem({
    super.key,
    required this.platformIcon,
    required this.title,
    required this.actionWidget,
    this.subtitle,
  });
  final PlatformIcon platformIcon;
  final String title;
  final String? subtitle;
  final Widget actionWidget;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p8),
        child: Column(
          children: [
            Row(
              children: [
                FittedBox(child: platformIcon),
                gapW16,
                Expanded(child: BaseText.titleMedium(title)),
              ],
            ),
            if (subtitle != null) ...[gapH8, BaseText.bodyMedium(subtitle!)],
            gapH8,
            actionWidget,
          ],
        ),
      ),
    );
  }
}
