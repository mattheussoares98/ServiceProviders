import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/repositories/checklists_repository.dart';

@LazySingleton()
class WatchChecklistItemsRealtimeUseCase {
  const WatchChecklistItemsRealtimeUseCase({
    required ChecklistsRepository checklistsRepository,
  }) : _checklistsRepository = checklistsRepository;

  final ChecklistsRepository _checklistsRepository;

  Stream<RealtimeEvent<ChecklistItemEntity>> call({String? companyId}) =>
      _checklistsRepository.watchChecklistItemsRealtime(companyId: companyId);
}
