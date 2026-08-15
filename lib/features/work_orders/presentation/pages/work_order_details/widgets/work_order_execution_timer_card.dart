import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
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

    if (!status.showsExecutionTimer) {
      return const SizedBox.shrink();
    }

    final isRunning = status.isRunning;
    final isPaused = status.isPaused;

    // When on hold, find the active pause request (resumedAt == null)
    final activePauseRequest = isPaused
        ? (pauseRequests.where((p) => p.resumedAt == null).toList()
                ..sort((a, b) => b.pausedAt.compareTo(a.pausedAt)))
              .firstOrNull
        : null;

    // Calculate total accumulated paused seconds across completed pauses
    final completedPauseSeconds = pauseRequests
        .where((p) => p.resumedAt != null)
        .fold<int>(
          0,
          (sum, p) => sum + p.resumedAt!.difference(p.pausedAt).inSeconds,
        );

    final showTotalPause = pauseRequests.length >= 2;
    final hasActivePause = activePauseRequest != null;

    final statusColor = workOrder.status.color;
    final cardBgColor = statusColor.withValues(alpha: 0.12);
    final borderColor = statusColor.withValues(alpha: 0.4);
    final contentColor = statusColor;

    return Container(
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlatformIcon(
                materialIcon: isRunning
                    ? Icons.timer_outlined
                    : isPaused
                    ? Icons.pause_circle_filled_outlined
                    : Icons.check_circle_outline,
                cupertinoIcon: isRunning
                    ? CupertinoIcons.timer
                    : isPaused
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
                    BaseText.title(
                      isRunning
                          ? 'Tempo em execução'.hardcoded
                          : 'Tempo total ativo'.hardcoded,
                    ),
                    gapH4,
                    FormattedDurationTimerText(
                      startedAt: workOrder.startedAt,
                      initialAccumulatedSeconds:
                          workOrder.netActiveDuration ?? 0,
                      color: contentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasActivePause || showTotalPause) ...[
            gapH12,
            const Divider(height: 1),
            gapH12,
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: Sizes.p16,
                runSpacing: Sizes.p8,
                children: [
                  if (hasActivePause)
                    _PauseMetric(
                      label: 'Pausa atual'.hardcoded,
                      icon: const PlatformIcon(
                        materialIcon: Icons.pause_circle_outline,
                        cupertinoIcon: CupertinoIcons.pause_circle,
                      ),
                      startedAt: activePauseRequest.pausedAt,
                      isRunning: true,
                      color: contentColor,
                    ),
                  if (showTotalPause)
                    _PauseMetric(
                      label: 'Total pausado'.hardcoded,
                      icon: const PlatformIcon(
                        materialIcon: Icons.history_toggle_off,
                        cupertinoIcon: CupertinoIcons.arrow_clockwise_circle,
                      ),
                      startedAt: hasActivePause
                          ? activePauseRequest.pausedAt
                          : null,
                      initialAccumulatedSeconds: completedPauseSeconds,
                      isRunning: hasActivePause,
                      color: contentColor,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PauseMetric extends StatelessWidget {
  const _PauseMetric({
    required this.label,
    required this.icon,
    this.startedAt,
    this.initialAccumulatedSeconds = 0,
    required this.isRunning,
    required this.color,
  });

  final String label;
  final PlatformIcon icon;
  final DateTime? startedAt;
  final int initialAccumulatedSeconds;
  final bool isRunning;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon.copyWith(color: color, size: 16),
        gapW4,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            BaseText.title(label),
            FormattedDurationTimerText(
              startedAt: startedAt,
              initialAccumulatedSeconds: initialAccumulatedSeconds,
              isRunning: isRunning,
              color: color,
            ),
          ],
        ),
      ],
    );
  }
}
