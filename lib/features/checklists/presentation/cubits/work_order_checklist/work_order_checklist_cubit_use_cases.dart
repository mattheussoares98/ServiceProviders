import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/upload_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_checklist_items_by_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_work_order_checklist_answers_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/save_checklist_response_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/watch_checklist_answers_realtime_use_case.dart';

@LazySingleton()
class WorkOrderChecklistCubitUseCases {
  const WorkOrderChecklistCubitUseCases({
    required this.getChecklistItemsByTemplate,
    required this.getWorkOrderChecklistAnswers,
    required this.saveChecklistResponse,
    required this.watchChecklistAnswersRealtime,
    required this.pickAttachment,
    required this.uploadAttachment,
    required this.getSessionUser,
    required this.getActiveCompanyId,
  });

  final GetChecklistItemsByTemplateUseCase getChecklistItemsByTemplate;
  final GetWorkOrderChecklistAnswersUseCase getWorkOrderChecklistAnswers;
  final SaveChecklistResponseUseCase saveChecklistResponse;
  final WatchChecklistAnswersRealtimeUseCase watchChecklistAnswersRealtime;
  final PickAttachmentUseCase pickAttachment;
  final UploadAttachmentUseCase uploadAttachment;
  final GetSessionUserUseCase getSessionUser;
  final GetActiveCompanyIdUseCase getActiveCompanyId;
}
