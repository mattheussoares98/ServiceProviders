import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_checklist_items_by_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_work_order_checklist_answers_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/save_checklist_response_use_case.dart';

@LazySingleton()
class WorkOrderChecklistCubitUseCases {
  const WorkOrderChecklistCubitUseCases({
    required this.getChecklistItemsByTemplate,
    required this.getWorkOrderChecklistAnswers,
    required this.saveChecklistResponse,
  });

  final GetChecklistItemsByTemplateUseCase getChecklistItemsByTemplate;
  final GetWorkOrderChecklistAnswersUseCase getWorkOrderChecklistAnswers;
  final SaveChecklistResponseUseCase saveChecklistResponse;
}
