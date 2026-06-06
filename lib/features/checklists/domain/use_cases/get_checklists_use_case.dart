import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:clean_architecture/features/checklists/domain/repositories/checklists_repository.dart';
import 'package:injectable/injectable.dart';

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
