import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_rich_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/formatted_duration_timer_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class ActiveStopwatchCard extends StatelessWidget {
  const ActiveStopwatchCard({
    super.key,
    required this.workOrder,
    required this.onTap,
  });

  final WorkOrderEntity workOrder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.p16),
        side: BorderSide(
          color: Colors.amber.withValues(alpha: isDark ? 0.3 : 0.5),
          width: 1.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Sizes.p16),
          gradient: LinearGradient(
            colors: [
              Colors.amber.withValues(alpha: isDark ? 0.12 : 0.06),
              Colors.amber.withValues(alpha: isDark ? 0.04 : 0.01),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Sizes.p16),
          child: Padding(
            padding: const EdgeInsets.all(Sizes.p8),
            child: Column(
              mainAxisAlignment: .spaceEvenly,
              children: [
                BaseText.title(
                  workOrder.title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                BaseRichText(
                  color: workOrder.priority.color,
                  maxLines: 2,
                  texts: [
                    BaseText('Prioridade '.hardcoded),
                    BaseText(workOrder.priority.label.toLowerCase()),
                  ],
                ),
                FittedBox(
                  child: FormattedDurationTimerText(
                    startedAt: workOrder.startedAt,
                    initialAccumulatedSeconds: workOrder.netActiveDuration ?? 0,
                    isRunning: workOrder.status == WorkOrderStatus.inProgress,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
