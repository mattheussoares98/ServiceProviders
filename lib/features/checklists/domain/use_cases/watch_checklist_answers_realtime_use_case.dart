import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/repositories/checklists_repository.dart';

@LazySingleton()
class WatchChecklistAnswersRealtimeUseCase {
  const WatchChecklistAnswersRealtimeUseCase({
    required ChecklistsRepository checklistsRepository,
  }) : _checklistsRepository = checklistsRepository;

  final ChecklistsRepository _checklistsRepository;

  Stream<RealtimeEvent<ChecklistAnswerEntity>> call({
    required String workOrderId,
  }) => _checklistsRepository.watchChecklistAnswersRealtime(
    workOrderId: workOrderId,
  );
}
