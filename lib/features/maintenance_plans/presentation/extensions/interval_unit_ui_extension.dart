import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/interval_unit.dart';

extension IntervalUnitUiExtension on IntervalUnit {
  String get label => switch (this) {
    IntervalUnit.days => 'Dias'.hardcoded,
    IntervalUnit.weeks => 'Semanas'.hardcoded,
    IntervalUnit.months => 'Meses'.hardcoded,
    IntervalUnit.years => 'Anos'.hardcoded,
  };

  String formatInterval(int value) => switch (this) {
    IntervalUnit.days =>
      value == 1 ? 'A cada 1 dia'.hardcoded : 'A cada $value dias'.hardcoded,
    IntervalUnit.weeks =>
      value == 1
          ? 'A cada 1 semana'.hardcoded
          : 'A cada $value semanas'.hardcoded,
    IntervalUnit.months =>
      value == 1 ? 'A cada 1 mês'.hardcoded : 'A cada $value meses'.hardcoded,
    IntervalUnit.years =>
      value == 1 ? 'A cada 1 ano'.hardcoded : 'A cada $value anos'.hardcoded,
  };
}
