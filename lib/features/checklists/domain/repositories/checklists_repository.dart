import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';

abstract interface class ChecklistsRepository {
  // Templates
  FutureList<ChecklistTemplateEntity> getTemplates(String companyId);
  FutureData<ChecklistTemplateEntity> getTemplateById(String id);
  FutureBool createTemplate(ChecklistTemplateEntity template);
  FutureBool updateTemplate(ChecklistTemplateEntity template);
  FutureBool deleteTemplate(String id);
  Stream<RealtimeEvent<ChecklistTemplateEntity>> watchChecklistTemplatesRealtime({
    String? companyId,
  });

  // Items
  FutureList<ChecklistItemEntity> getItemsByTemplate(String templateId);
  FutureBool createItem(ChecklistItemEntity item);
  FutureBool updateItem(ChecklistItemEntity item);
  FutureBool deleteItem(String id);
  Stream<RealtimeEvent<ChecklistItemEntity>> watchChecklistItemsRealtime({
    String? companyId,
  });

  // Execution Responses
  FutureList<ChecklistAnswerEntity> getResponsesByWorkOrder(String workOrderId);
  FutureBool saveResponse(ChecklistAnswerEntity response);
}
