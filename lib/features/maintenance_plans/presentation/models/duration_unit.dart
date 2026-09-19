import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';

enum DurationUnit {
  hours('hours'),
  days('days'),
  weeks('weeks'),
  months('months');

  const DurationUnit(this.code);
  final String code;

  String get label => switch (this) {
    DurationUnit.hours => 'Horas'.hardcoded,
    DurationUnit.days => 'Dias'.hardcoded,
    DurationUnit.weeks => 'Semanas'.hardcoded,
    DurationUnit.months => 'Meses'.hardcoded,
  };

  /// Converts a user entered value in this unit to hours (saved in DB as integer hours).
  int toHours(double value) => switch (this) {
    DurationUnit.hours => value.round().clamp(1, 999999),
    DurationUnit.days => (value * 24).round().clamp(1, 999999),
    DurationUnit.weeks => (value * 24 * 7).round().clamp(1, 999999),
    DurationUnit.months => (value * 24 * 30).round().clamp(1, 999999),
  };

  /// Helper to convert hours back into the most appropriate unit for display
  static (DurationUnit, int) fromHours(int totalHours) {
    if (totalHours <= 0) return (DurationUnit.hours, 1);
    if (totalHours % (24 * 30) == 0) {
      return (DurationUnit.months, totalHours ~/ (24 * 30));
    }
    if (totalHours % (24 * 7) == 0) {
      return (DurationUnit.weeks, totalHours ~/ (24 * 7));
    }
    if (totalHours % 24 == 0) {
      return (DurationUnit.days, totalHours ~/ 24);
    }
    return (DurationUnit.hours, totalHours);
  }

  static String formatDuration(int totalHours) {
    final (unit, val) = DurationUnit.fromHours(totalHours);
    return switch (unit) {
      DurationUnit.hours =>
        val == 1 ? '1 hora'.hardcoded : '$val horas'.hardcoded,
      DurationUnit.days =>
        val == 1 ? '1 dia'.hardcoded : '$val dias'.hardcoded,
      DurationUnit.weeks =>
        val == 1 ? '1 semana'.hardcoded : '$val semanas'.hardcoded,
      DurationUnit.months =>
        val == 1 ? '1 mês'.hardcoded : '$val meses'.hardcoded,
    };
  }
}
