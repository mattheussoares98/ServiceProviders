import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/repositories/checklists_repository.dart';

@LazySingleton()
class GetWorkOrderChecklistAnswersUseCase
    implements UseCase<List<ChecklistAnswerEntity>, String> {
  const GetWorkOrderChecklistAnswersUseCase({
    required ChecklistsRepository checklistsRepository,
  }) : _checklistsRepository = checklistsRepository;

  final ChecklistsRepository _checklistsRepository;

  @override
  FutureList<ChecklistAnswerEntity> call(String request) =>
      _checklistsRepository.getResponsesByWorkOrder(request);
}
