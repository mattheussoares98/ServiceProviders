import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class BaseEmptyState extends HookWidget {
  const BaseEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    required this.icon,
    this.canPerformAction = true,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;
  final PlatformIcon icon;
  final bool canPerformAction;

  @override
  Widget build(BuildContext context) {
    final isTickerEnabled = TickerMode.valuesOf(context).enabled;
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1800),
    );

    useEffect(() {
      if (isTickerEnabled) {
        controller.repeat(reverse: true);
      } else {
        controller.stop();
      }
      return null;
    }, [controller, isTickerEnabled]);

    final pulseAnimation = useMemoized(
      () => Tween<double>(
        begin: 1,
        end: 1.08,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
      [controller],
    );

    final glowAnimation = useMemoized(
      () => Tween<double>(
        begin: 0.12,
        end: 0.28,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
      [controller],
    );

    final primaryColor = context.colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              child: GestureDetector(
                onTap: onAction,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: pulseAnimation.value,
                      child: Container(
                        width: Sizes.p80,
                        height: Sizes.p80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withValues(alpha: 0.1),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(
                                alpha: glowAnimation.value,
                              ),
                              blurRadius: Sizes.p24,
                              spreadRadius: Sizes.p8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: PlatformIcon(
                            materialIcon: icon.materialIcon,
                            cupertinoIcon: icon.cupertinoIcon,
                            color: icon.color ?? primaryColor,
                            size: icon.size ?? Sizes.p40,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gapH24,
            BaseText(
              title,
              textType: TextType.titleMedium,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            gapH8,
            BaseText.bodySmall(
              description,
              textAlign: TextAlign.center,
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            gapH24,
            if (canPerformAction)
              BaseButton(text: actionLabel, onTap: onAction),
          ],
        ),
      ),
    );
  }
}
