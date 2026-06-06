import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/checklists/data/data_sources/checklists_local_data_source.dart';
import 'package:clean_architecture/features/checklists/data/data_sources/checklists_remote_data_source.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:clean_architecture/features/checklists/domain/repositories/checklists_repository.dart';
import 'package:injectable/injectable.dart';

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

  // TODO: Wire to local/remote data sources with RepositoryHandler
  @override
  FutureList<ChecklistTemplateEntity> getTemplates(String companyId) =>
      throw UnimplementedError();

  @override
  FutureData<ChecklistTemplateEntity> getTemplateById(String id) =>
      throw UnimplementedError();

  @override
  FutureBool createTemplate(ChecklistTemplateEntity template) =>
      throw UnimplementedError();

  @override
  FutureBool updateTemplate(ChecklistTemplateEntity template) =>
      throw UnimplementedError();

  @override
  FutureBool deleteTemplate(String id) => throw UnimplementedError();

  @override
  FutureList<ChecklistItemEntity> getItemsByTemplate(String templateId) =>
      throw UnimplementedError();

  @override
  FutureBool createItem(ChecklistItemEntity item) =>
      throw UnimplementedError();

  @override
  FutureBool updateItem(ChecklistItemEntity item) =>
      throw UnimplementedError();

  @override
  FutureBool deleteItem(String id) => throw UnimplementedError();
}
