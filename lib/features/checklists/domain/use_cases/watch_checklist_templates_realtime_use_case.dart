import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/repositories/checklists_repository.dart';

@LazySingleton()
class WatchChecklistTemplatesRealtimeUseCase {
  const WatchChecklistTemplatesRealtimeUseCase({
    required ChecklistsRepository checklistsRepository,
  }) : _checklistsRepository = checklistsRepository;

  final ChecklistsRepository _checklistsRepository;

  Stream<RealtimeEvent<ChecklistTemplateEntity>> call({String? companyId}) =>
      _checklistsRepository.watchChecklistTemplatesRealtime(
        companyId: companyId,
      );
}
