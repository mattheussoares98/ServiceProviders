import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_applies_to.dart';

extension SlaAppliesToUiExtension on SlaAppliesTo {
  String get label => switch (this) {
    SlaAppliesTo.provider => 'Prestador'.hardcoded,
    SlaAppliesTo.contractor => 'Contratante'.hardcoded,
    SlaAppliesTo.both => 'Ambos'.hardcoded,
  };
}
