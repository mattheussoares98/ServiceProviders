import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/repositories/checklists_repository.dart';

@LazySingleton()
class SaveChecklistResponseUseCase
    implements UseCase<bool, ChecklistAnswerEntity> {
  SaveChecklistResponseUseCase({
    required ChecklistsRepository checklistsRepository,
  }) : _checklistsRepository = checklistsRepository;

  final ChecklistsRepository _checklistsRepository;

  @override
  FutureBool call(ChecklistAnswerEntity request) =>
      _checklistsRepository.saveResponse(request);
}
