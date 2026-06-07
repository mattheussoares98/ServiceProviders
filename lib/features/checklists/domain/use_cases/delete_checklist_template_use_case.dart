import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/checklists/domain/repositories/checklists_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class DeleteChecklistTemplateUseCase implements UseCase<bool, String> {
  const DeleteChecklistTemplateUseCase({
    required ChecklistsRepository checklistsRepository,
  }) : _checklistsRepository = checklistsRepository;

  final ChecklistsRepository _checklistsRepository;

  @override
  FutureBool call(String request) =>
      _checklistsRepository.deleteTemplate(request);
}
