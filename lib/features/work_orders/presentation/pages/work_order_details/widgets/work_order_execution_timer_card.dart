import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/formatted_duration_timer_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

/// A card displaying the real-time execution timer for in-progress work orders,
/// or elapsed duration summary when on hold or completed.
class WorkOrderExecutionTimerCard extends StatelessWidget {
  const WorkOrderExecutionTimerCard({
    super.key,
    required this.workOrder,
    this.pauseRequests = const [],
  });

  final WorkOrderEntity workOrder;
  final List<PauseRequestEntity> pauseRequests;

  @override
  Widget build(BuildContext context) {
    final status = workOrder.status;

    if (status != WorkOrderStatus.inProgress &&
        status != WorkOrderStatus.onHold &&
        status != WorkOrderStatus.completed) {
      return const SizedBox.shrink();
    }

    final isRunning = status == WorkOrderStatus.inProgress;
    final isOnHold = status == WorkOrderStatus.onHold;

    // When on hold, find the latest active pause request to calculate elapsed pause time
    final activePauseRequest = isOnHold
        ? (pauseRequests.where((p) => p.resumedAt == null).toList()
                ..sort((a, b) => b.pausedAt.compareTo(a.pausedAt)))
              .firstOrNull
        : null;

    final statusColor = workOrder.status.color;
    final cardBgColor = statusColor.withValues(alpha: 0.15);
    final borderColor = statusColor.withValues(alpha: 0.5);
    final contentColor = statusColor;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Sizes.p16,
        vertical: Sizes.p8,
      ),
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          PlatformIcon(
            materialIcon: isRunning
                ? Icons.timer_outlined
                : isOnHold
                ? Icons.pause_circle_filled_outlined
                : Icons.check_circle_outline,
            cupertinoIcon: isRunning
                ? CupertinoIcons.timer
                : isOnHold
                ? CupertinoIcons.pause_circle_fill
                : CupertinoIcons.check_mark_circled,
            color: contentColor,
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
                      : isOnHold
                      ? 'Tempo pausado'.hardcoded
                      : 'Tempo total ativo'.hardcoded,
                  color: contentColor,
                ),
                gapH4,
                FormattedDurationTimerText(
                  startedAt: isOnHold
                      ? activePauseRequest?.pausedAt
                      : workOrder.startedAt,
                  initialAccumulatedSeconds: isOnHold
                      ? 0
                      : (workOrder.netActiveDuration ?? 0),
                  isRunning: isRunning || isOnHold,
                  color: contentColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
