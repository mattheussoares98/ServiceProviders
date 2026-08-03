import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_response_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';

abstract interface class ChecklistsRepository {
  // Templates
  FutureList<ChecklistTemplateEntity> getTemplates(String companyId);
  FutureData<ChecklistTemplateEntity> getTemplateById(String id);
  FutureBool createTemplate(ChecklistTemplateEntity template);
  FutureBool updateTemplate(ChecklistTemplateEntity template);
  FutureBool deleteTemplate(String id);

  // Items
  FutureList<ChecklistItemEntity> getItemsByTemplate(String templateId);
  FutureBool createItem(ChecklistItemEntity item);
  FutureBool updateItem(ChecklistItemEntity item);
  FutureBool deleteItem(String id);

  // Execution Responses
  FutureList<ChecklistResponseAnswerEntity> getResponsesByWorkOrder(
    String workOrderId,
  );
  FutureBool saveResponse(ChecklistResponseAnswerEntity response);
}
