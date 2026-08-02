import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/formatted_duration_timer_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

/// A card displaying the real-time execution timer for in-progress work orders,
/// or elapsed duration summary when on hold or completed.
class WorkOrderExecutionTimerCard extends StatelessWidget {
  const WorkOrderExecutionTimerCard({super.key, required this.workOrder});

  final WorkOrderEntity workOrder;

  @override
  Widget build(BuildContext context) {
    final status = workOrder.status;

    if (status != WorkOrderStatus.inProgress &&
        status != WorkOrderStatus.onHold &&
        status != WorkOrderStatus.completed) {
      return const SizedBox.shrink();
    }

    final isRunning = status == WorkOrderStatus.inProgress;
    final colorScheme = context.theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Sizes.p16,
        vertical: Sizes.p8,
      ),
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: isRunning
            ? colorScheme.primaryContainer.withValues(alpha: 0.25)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(
          color: isRunning
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          PlatformIcon(
            materialIcon: isRunning
                ? Icons.timer_outlined
                : Icons.pause_circle_outline,
            cupertinoIcon: isRunning
                ? CupertinoIcons.timer
                : CupertinoIcons.pause_circle,
            color: isRunning
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: Sizes.p24,
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseText.caption(
                  isRunning
                      ? 'Tempo em execução'.hardcoded
                      : 'Tempo total ativo'.hardcoded,
                  color: colorScheme.onSurfaceVariant,
                ),
                gapH4,
                FormattedDurationTimerText(
                  startedAt: workOrder.startedAt,
                  initialAccumulatedSeconds: workOrder.netActiveDuration ?? 0,
                  isRunning: isRunning,
                  color: isRunning
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
