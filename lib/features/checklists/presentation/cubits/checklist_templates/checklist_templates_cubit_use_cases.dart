import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/create_checklist_item_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/create_checklist_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/delete_checklist_item_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/delete_checklist_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_checklist_items_by_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_checklist_template_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_checklists_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/update_checklist_item_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/update_checklist_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/watch_checklist_items_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/watch_checklist_templates_realtime_use_case.dart';

@LazySingleton()
class ChecklistTemplatesCubitUseCases {
  const ChecklistTemplatesCubitUseCases({
    required this.getActiveCompanyId,
    required this.getChecklists,
    required this.getChecklistTemplateById,
    required this.createChecklistTemplate,
    required this.updateChecklistTemplate,
    required this.deleteChecklistTemplate,
    required this.watchChecklistTemplatesRealtime,
    required this.getChecklistItemsByTemplate,
    required this.createChecklistItem,
    required this.updateChecklistItem,
    required this.deleteChecklistItem,
    required this.watchChecklistItemsRealtime,
  });

  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final GetChecklistsUseCase getChecklists;
  final GetChecklistTemplateByIdUseCase getChecklistTemplateById;
  final CreateChecklistTemplateUseCase createChecklistTemplate;
  final UpdateChecklistTemplateUseCase updateChecklistTemplate;
  final DeleteChecklistTemplateUseCase deleteChecklistTemplate;
  final WatchChecklistTemplatesRealtimeUseCase watchChecklistTemplatesRealtime;
  final GetChecklistItemsByTemplateUseCase getChecklistItemsByTemplate;
  final CreateChecklistItemUseCase createChecklistItem;
  final UpdateChecklistItemUseCase updateChecklistItem;
  final DeleteChecklistItemUseCase deleteChecklistItem;
  final WatchChecklistItemsRealtimeUseCase watchChecklistItemsRealtime;
}
