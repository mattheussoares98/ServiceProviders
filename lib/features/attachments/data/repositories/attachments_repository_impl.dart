import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/data/handlers/repository_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/attachments/data/data_sources/attachments_local_data_source.dart';
import 'package:clean_architecture/features/attachments/data/data_sources/attachments_remote_data_source.dart';
import 'package:clean_architecture/features/attachments/data/models/responses/attachment_response_model.dart';
import 'package:clean_architecture/features/attachments/domain/entities/attachment_entity.dart';
import 'package:clean_architecture/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AttachmentsRepository)
final class AttachmentsRepositoryImpl implements AttachmentsRepository {
  AttachmentsRepositoryImpl({
    required InternetClient internet,
    required AttachmentsRemoteDataSource remoteDataSource,
    required AttachmentsLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final AttachmentsRemoteDataSource _remoteDataSource;
  final AttachmentsLocalDataSource _localDataSource;

  @override
  FutureList<AttachmentEntity> getAttachmentsByWorkOrder(String workOrderId) =>
      RepositoryHandler.fetchFromLocalAndMapList<
        AttachmentResponseModel,
        AttachmentEntity
      >(localCallback: () => _localDataSource.getAttachmentsByWorkOrder(workOrderId));

  @override
  FutureBool createAttachment(AttachmentEntity attachment) =>
      _localDataSource.saveAttachment(AttachmentResponseModel.fromEntity(attachment));

  @override
  FutureBool deleteAttachment(String id) => _localDataSource.deleteAttachment(id);
}
