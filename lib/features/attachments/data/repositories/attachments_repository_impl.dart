import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_local_data_source.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_response_model.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';

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
      >(
        localCallback: () =>
            _localDataSource.getAttachmentsByWorkOrder(workOrderId),
      );

  @override
  FutureBool createAttachment(AttachmentEntity attachment) => _localDataSource
      .saveAttachment(AttachmentResponseModel.fromEntity(attachment));

  @override
  FutureBool deleteAttachment(String id) =>
      _localDataSource.deleteAttachment(id);
}
