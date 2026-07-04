import 'dart:async';

import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ActiveStopwatchCard extends HookWidget {
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

    // Local state to force rebuild every second and display current duration
    final elapsedSeconds = useState<int>(0);

    useEffect(() {
      final startedAt = workOrder.startedAt;
      if (startedAt == null) return null;

      // Update helper
      void updateTimer() {
        final diff = DateTime.now().difference(startedAt);
        elapsedSeconds.value = diff.inSeconds;
      }

      updateTimer();
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        updateTimer();
      });

      return timer.cancel;
    }, [workOrder.startedAt]);

    String formatDuration(int totalSeconds) {
      int baseSeconds = totalSeconds;
      if (totalSeconds < 0) baseSeconds = 0;
      final hours = baseSeconds ~/ 3600;
      final minutes = (baseSeconds % 3600) ~/ 60;
      final seconds = baseSeconds % 60;

      final hoursStr = hours.toString().padLeft(2, '0');
      final minutesStr = minutes.toString().padLeft(2, '0');
      final secondsStr = seconds.toString().padLeft(2, '0');

      return '$hoursStr:$minutesStr:$secondsStr';
    }

    final durationText = formatDuration(elapsedSeconds.value);

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
            padding: const EdgeInsets.all(Sizes.p16),
            child: Row(
              children: [
                // Pulsing play icon
                Container(
                  padding: const EdgeInsets.all(Sizes.p12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const PlatformIcon(
                    materialIcon: Icons.play_circle_filled,
                    cupertinoIcon: CupertinoIcons.play_circle,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
                gapW16,
                // Work order info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BaseText.headline(
                        'TRABALHO EM ANDAMENTO'.hardcoded,
                        color: Colors.amber.shade800,
                      ),
                      gapH4,
                      BaseText.title(workOrder.title),
                      gapH4,
                      BaseText(
                        'Prioridade: ${workOrder.priority.label}'.hardcoded,
                      ),
                    ],
                  ),
                ),
                gapW12,
                // Time counter
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BaseText.title(durationText, color: Colors.amber.shade800),
                    gapH4,
                    BaseText('Visualizar'.hardcoded),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
