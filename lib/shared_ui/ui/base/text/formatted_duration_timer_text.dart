import 'dart:async';

import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class FormattedDurationTimerText extends StatefulWidget {
  const FormattedDurationTimerText({
    super.key,
    this.startedAt,
    this.initialAccumulatedSeconds = 0,
    this.isRunning = true,
    this.color,
    this.fontWeight = FontWeight.bold,
  });

  final DateTime? startedAt;
  final int initialAccumulatedSeconds;
  final bool isRunning;
  final Color? color;
  final FontWeight fontWeight;

  static String formatDuration(Duration duration) =>
      _FormattedDurationTimerTextState.formatDuration(duration);

  @override
  State<FormattedDurationTimerText> createState() =>
      _FormattedDurationTimerTextState();
}

class _FormattedDurationTimerTextState
    extends State<FormattedDurationTimerText> {
  Timer? _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _calculateElapsed();
    if (widget.isRunning && widget.startedAt != null) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant FormattedDurationTimerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateElapsed();
    if (widget.isRunning && widget.startedAt != null) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(_calculateElapsed);
      }
    });
  }

  void _calculateElapsed() {
    final baseSeconds = widget.initialAccumulatedSeconds;
    if (widget.isRunning && widget.startedAt != null) {
      final runningSeconds = DateTime.now()
          .difference(widget.startedAt!)
          .inSeconds;
      _elapsed = Duration(seconds: baseSeconds + runningSeconds);
    } else {
      _elapsed = Duration(seconds: baseSeconds);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static String _joinParts(List<String> parts) {
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first;
    if (parts.length == 2) return '${parts[0]} e ${parts[1]}';
    return '${parts.sublist(0, parts.length - 1).join(', ')} e ${parts.last}';
  }

  static String formatDuration(Duration duration) {
    final totalDays = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final mStr = '${minutes}m';
    final sStr = '${seconds}s';

    // Less than 1 day: show hours, minutes, and seconds
    if (totalDays < 1) {
      final hStr = hours > 0 ? '${hours}h' : null;
      return _joinParts([?hStr, mStr, sStr]);
    }

    // Less than 1 week (1 to 6 days): show days, hours, minutes, and seconds
    if (totalDays < 7) {
      final daysStr = totalDays == 1
          ? '1 dia'.hardcoded
          : '$totalDays dias'.hardcoded;
      final hStr = hours > 0 ? '${hours}h' : null;
      return _joinParts([daysStr, ?hStr, mStr, sStr]);
    }

    // Less than 1 month (7 to 29 days): show weeks, days, hours, minutes, and seconds
    if (totalDays < 30) {
      final weeks = totalDays ~/ 7;
      final remainingDays = totalDays % 7;

      final wStr = weeks == 1 ? '1 sem'.hardcoded : '$weeks sem'.hardcoded;
      final dStr = remainingDays > 0
          ? (remainingDays == 1
                ? '1 dia'.hardcoded
                : '$remainingDays dias'.hardcoded)
          : null;
      final hStr = hours > 0 ? '${hours}h' : null;

      return _joinParts([wStr, ?dStr, ?hStr, mStr, sStr]);
    }

    // 1 month or greater (>= 30 days): show months, weeks, days, hours, minutes, and seconds
    final months = totalDays ~/ 30;
    final daysAfterMonths = totalDays % 30;
    final weeks = daysAfterMonths ~/ 7;
    final remainingDays = daysAfterMonths % 7;

    final monthStr = months == 1
        ? '1 mês'.hardcoded
        : '$months meses'.hardcoded;
    final wStr = weeks > 0
        ? (weeks == 1 ? '1 sem'.hardcoded : '$weeks sem'.hardcoded)
        : null;
    final dStr = remainingDays > 0
        ? (remainingDays == 1
              ? '1 dia'.hardcoded
              : '$remainingDays dias'.hardcoded)
        : null;
    final hStr = hours > 0 ? '${hours}h' : null;

    return _joinParts([monthStr, ?wStr, ?dStr, ?hStr, mStr, sStr]);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BaseText.headline(
        formatDuration(_elapsed),
        fontWeight: widget.fontWeight,
        color: widget.color,
      ),
    );
  }
}
