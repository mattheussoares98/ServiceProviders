import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/repositories/checklists_repository.dart';

class GetWorkOrderChecklistAnswersBatchParams {
  const GetWorkOrderChecklistAnswersBatchParams({
    required this.workOrderIds,
    this.since,
  });

  final List<String> workOrderIds;
  final DateTime? since;
}

@LazySingleton()
class GetWorkOrderChecklistAnswersBatchUseCase
    implements
        UseCase<
          List<ChecklistAnswerEntity>,
          GetWorkOrderChecklistAnswersBatchParams
        > {
  const GetWorkOrderChecklistAnswersBatchUseCase({
    required ChecklistsRepository checklistsRepository,
  }) : _checklistsRepository = checklistsRepository;

  final ChecklistsRepository _checklistsRepository;

  @override
  FutureList<ChecklistAnswerEntity> call(
    GetWorkOrderChecklistAnswersBatchParams params,
  ) => _checklistsRepository.getResponsesByWorkOrderIds(
    params.workOrderIds,
    since: params.since,
  );
}
