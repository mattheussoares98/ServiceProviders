import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/data/data_sources/checklists_local_data_source.dart';
import 'package:o_jogo_da_obra/features/checklists/data/data_sources/checklists_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_item_response_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_template_response_model.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/repositories/checklists_repository.dart';

@LazySingleton(as: ChecklistsRepository)
final class ChecklistsRepositoryImpl implements ChecklistsRepository {
  ChecklistsRepositoryImpl({
    required InternetClient internet,
    required ChecklistsRemoteDataSource remoteDataSource,
    required ChecklistsLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final ChecklistsRemoteDataSource _remoteDataSource;
  final ChecklistsLocalDataSource _localDataSource;

  @override
  FutureList<ChecklistTemplateEntity> getTemplates(String companyId) =>
      RepositoryHandler.fetchFromLocalAndMapList<
        ChecklistTemplateResponseModel,
        ChecklistTemplateEntity
      >(localCallback: () => _localDataSource.getTemplates(companyId));

  @override
  FutureData<ChecklistTemplateEntity> getTemplateById(String id) =>
      RepositoryHandler.fetchFromLocalAndMap<
        ChecklistTemplateResponseModel,
        ChecklistTemplateEntity
      >(localCallback: () => _localDataSource.getTemplateById(id));

  @override
  FutureBool createTemplate(ChecklistTemplateEntity template) =>
      _localDataSource.saveTemplate(
        ChecklistTemplateResponseModel.fromEntity(template),
      );

  @override
  FutureBool updateTemplate(ChecklistTemplateEntity template) =>
      _localDataSource.saveTemplate(
        ChecklistTemplateResponseModel.fromEntity(template),
      );

  @override
  FutureBool deleteTemplate(String id) => _localDataSource.deleteTemplate(id);

  @override
  FutureList<ChecklistItemEntity> getItemsByTemplate(String templateId) =>
      RepositoryHandler.fetchFromLocalAndMapList<
        ChecklistItemResponseModel,
        ChecklistItemEntity
      >(localCallback: () => _localDataSource.getItemsByTemplate(templateId));

  @override
  FutureBool createItem(ChecklistItemEntity item) =>
      _localDataSource.saveItem(ChecklistItemResponseModel.fromEntity(item));

  @override
  FutureBool updateItem(ChecklistItemEntity item) =>
      _localDataSource.saveItem(ChecklistItemResponseModel.fromEntity(item));

  @override
  FutureBool deleteItem(String id) => _localDataSource.deleteItem(id);
}
