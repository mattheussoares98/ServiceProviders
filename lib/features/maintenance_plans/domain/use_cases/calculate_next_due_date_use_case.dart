import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/interval_unit.dart';

class RecurrenceParams {
  const RecurrenceParams({
    required this.baseDate,
    required this.intervalValue,
    required this.intervalUnit,
    this.dayOfWeek,
    this.dayOfMonth,
    this.monthOfYear,
  });

  final DateTime baseDate;
  final int intervalValue;
  final IntervalUnit intervalUnit;
  final int? dayOfWeek;
  final int? dayOfMonth;
  final int? monthOfYear;
}

@LazySingleton()
class CalculateNextDueDateUseCase
    implements UseCaseSynchronous<DateTime, RecurrenceParams> {
  const CalculateNextDueDateUseCase();

  @override
  DateTime call(RecurrenceParams params) {
    final base = params.baseDate.toUtc();
    final value = params.intervalValue > 0 ? params.intervalValue : 1;

    switch (params.intervalUnit) {
      case IntervalUnit.days:
        return base.add(Duration(days: value));

      case IntervalUnit.weeks:
        var next = base.add(Duration(days: value * 7));
        if (params.dayOfWeek != null &&
            params.dayOfWeek! >= 1 &&
            params.dayOfWeek! <= 7) {
          final diff = params.dayOfWeek! - next.weekday;
          next = next.add(Duration(days: diff));
          if (next.isBefore(base) || next.isAtSameMomentAs(base)) {
            next = next.add(const Duration(days: 7));
          }
        }
        return next;

      case IntervalUnit.months:
        final desiredDay = params.dayOfMonth ?? base.day;
        final candidate = DateTime.utc(
          base.year,
          base.month + value,
          desiredDay,
          base.hour,
          base.minute,
          base.second,
        );
        // Dart's DateTime.utc auto-overflows 31 Feb -> 3 Mar. If the month shifted past expected, clamp to last day of previous month.
        final expectedMonth = ((base.month - 1 + value) % 12) + 1;
        if (candidate.month != expectedMonth) {
          return DateTime.utc(
            candidate.year,
            candidate.month,
            0,
            base.hour,
            base.minute,
            base.second,
          );
        }
        return candidate;

      case IntervalUnit.years:
        final desiredMonth = params.monthOfYear ?? base.month;
        final desiredDay = params.dayOfMonth ?? base.day;
        final candidate = DateTime.utc(
          base.year + value,
          desiredMonth,
          desiredDay,
          base.hour,
          base.minute,
          base.second,
        );
        if (candidate.month != desiredMonth) {
          return DateTime.utc(
            candidate.year,
            candidate.month,
            0,
            base.hour,
            base.minute,
            base.second,
          );
        }
        return candidate;
    }
  }
}
