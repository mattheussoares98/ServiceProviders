import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';

import 'factory_helpers.dart';

abstract final class ChecklistFactory {
  static ChecklistTemplateEntity makeChecklistTemplateEntity() {
    return ChecklistTemplateEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makeCompanyName(),
      description: FactoryHelpers.makePhrase(),
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      categoryId: null,
      deletedAt: null,
    );
  }

  static List<ChecklistTemplateEntity> makeChecklistTemplateEntityList() {
    return [
      makeChecklistTemplateEntity(),
      makeChecklistTemplateEntity(),
      makeChecklistTemplateEntity(),
    ];
  }

  // ChecklistItem
  static ChecklistItemEntity makeChecklistItemEntity() {
    return ChecklistItemEntity(
      id: FactoryHelpers.makeId(),
      templateId: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      label: FactoryHelpers.makeWord(),
      type: ChecklistItemType.boolean,
      isRequired: false,
      sortOrder: FactoryHelpers.makeInt(10),
      createdAt: FactoryHelpers.makeDateTime(),
      deletedAt: null,
      options: null,
    );
  }

  static List<ChecklistItemEntity> makeChecklistItemEntityList() {
    return [
      makeChecklistItemEntity(),
      makeChecklistItemEntity(),
      makeChecklistItemEntity(),
    ];
  }

  // ChecklistAnswer
  static ChecklistAnswerEntity makeChecklistAnswerEntity() {
    return ChecklistAnswerEntity(
      id: FactoryHelpers.makeId(),
      workOrderId: FactoryHelpers.makeId(),
      checklistItemId: FactoryHelpers.makeId(),
      booleanValue: FactoryHelpers.makeBool(),
      textValue: FactoryHelpers.makePhrase(),
      numberValue: FactoryHelpers.makeDouble(),
      photoUrl: FactoryHelpers.makeHttps(),
      selectedOption: FactoryHelpers.makeWord(),
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
    );
  }

  static List<ChecklistAnswerEntity> makeChecklistAnswerEntityList() {
    return [
      makeChecklistAnswerEntity(),
      makeChecklistAnswerEntity(),
      makeChecklistAnswerEntity(),
    ];
  }
}
