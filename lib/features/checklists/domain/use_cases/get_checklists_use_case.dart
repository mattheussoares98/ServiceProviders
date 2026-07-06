import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/repositories/checklists_repository.dart';

@LazySingleton()
class GetChecklistsUseCase
    implements UseCase<List<ChecklistTemplateEntity>, String> {
  GetChecklistsUseCase({required ChecklistsRepository checklistsRepository})
    : _checklistsRepository = checklistsRepository;

  final ChecklistsRepository _checklistsRepository;

  @override
  FutureList<ChecklistTemplateEntity> call(String request) =>
      _checklistsRepository.getTemplates(request);
}
