import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';

extension ChecklistItemTypeUiExtension on ChecklistItemType {
  String get label => switch (this) {
    ChecklistItemType.boolean => 'Sim/Não'.hardcoded,
    ChecklistItemType.text => 'Texto Livre'.hardcoded,
    ChecklistItemType.number => 'Numérico'.hardcoded,
    ChecklistItemType.photo => 'Foto'.hardcoded,
    ChecklistItemType.documentation => 'Documentação'.hardcoded,
    ChecklistItemType.selection => 'Múltipla Escolha'.hardcoded,
  };
}
