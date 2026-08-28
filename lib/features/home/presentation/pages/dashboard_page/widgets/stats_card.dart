import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.title,
    this.value,
    this.valueWidget,
    required this.icon,
    required this.color,
    this.onTap,
  }) : assert(
          value != null || valueWidget != null,
          'Either value or valueWidget must be provided',
        );

  final String title;
  final String? value;
  final Widget? valueWidget;
  final PlatformIcon icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Sizes.p16),
        child: Container(
          padding: const EdgeInsets.all(Sizes.p8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: isDark ? 0.15 : 0.08),
                color.withValues(alpha: isDark ? 0.05 : 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(Sizes.p16),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.25 : 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: .stretch,
            mainAxisAlignment: .spaceBetween,
            children: [
              Align(
                alignment: .centerLeft,
                child: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(Sizes.p8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: FittedBox(
                    child: icon.copyWith(color: color, size: 18),
                  ),
                ),
              ),
              gapH8,
              Column(
                crossAxisAlignment: .start,
                children: [
                  valueWidget ??
                      BaseText.headline(
                        value ?? '',
                        fontWeight: FontWeight.w900,
                        color: color,
                        overflow: TextOverflow.ellipsis,
                      ),
                  gapH4,
                  BaseText(
                    title,
                    color: context.theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
