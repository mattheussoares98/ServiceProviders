import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:clean_architecture/features/checklists/domain/repositories/checklists_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class UpdateChecklistItemUseCase implements UseCase<bool, ChecklistItemEntity> {
  const UpdateChecklistItemUseCase({
    required ChecklistsRepository checklistsRepository,
  }) : _checklistsRepository = checklistsRepository;

  final ChecklistsRepository _checklistsRepository;

  @override
  FutureBool call(ChecklistItemEntity request) =>
      _checklistsRepository.updateItem(request);
}
