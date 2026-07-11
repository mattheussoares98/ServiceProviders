import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

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
    this.messageIfSubtitleIsNull,
    this.titleColor,
    this.subtitleColor,
    this.icon,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final String? messageIfSubtitleIsNull;
  final TitleAndSubtitleType? type;
  final Color? titleColor;
  final Color? subtitleColor;
  final PlatformIcon? icon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    final String displaySubtitle = (subtitle == null || subtitle!.isEmpty)
        ? (messageIfSubtitleIsNull ?? '')
        : subtitle!;

    final isNullOrEmpty = subtitle == null || subtitle!.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.p8),
      padding: const EdgeInsets.all(Sizes.p8),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(Sizes.p8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: IconTheme(
                data: IconThemeData(color: colorScheme.primary, size: 20),
                child: icon!,
              ),
            ),
            gapW16,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BaseText.caption(
                  title.toUpperCase(),
                  color:
                      titleColor ??
                      colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
                gapH4,
                Row(
                  crossAxisAlignment: .baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    if (type == TitleAndSubtitleType.money) ...[
                      BaseText.bodySmall(
                        '${type!.label} ',
                        color: subtitleColor ?? colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                    Expanded(
                      child: BaseText.bodyLarge(
                        displaySubtitle,
                        color: isNullOrEmpty
                            ? colorScheme.onSurface.withValues(alpha: 0.38)
                            : (subtitleColor ?? colorScheme.onSurface),
                        fontWeight: isNullOrEmpty
                            ? FontWeight.normal
                            : FontWeight.w600,
                        fontStyle: isNullOrEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                    if (type == TitleAndSubtitleType.percentage) ...[
                      BaseText.bodySmall(
                        ' ${type!.label}',
                        color: subtitleColor ?? colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
