import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/handlers/error_handler.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/attachments/data/models/responses/attachment_response_model.dart';
import 'package:clean_architecture/features/attachments/domain/entities/file_type.dart';
import 'package:clean_architecture/features/attachments/domain/entities/upload_status.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

abstract interface class AttachmentsLocalDataSource {
  FutureList<AttachmentResponseModel> getAttachmentsByWorkOrder(String workOrderId);
  FutureBool saveAttachment(AttachmentResponseModel attachment);
  FutureBool deleteAttachment(String id);
}

@LazySingleton(as: AttachmentsLocalDataSource)
final class AttachmentsLocalDataSourceImpl implements AttachmentsLocalDataSource {
  AttachmentsLocalDataSourceImpl({
    required AppDatabase database,
  }) : _database = database;

  final AppDatabase _database;

  @override
  FutureList<AttachmentResponseModel> getAttachmentsByWorkOrder(String workOrderId) {
    return ErrorHandler.execute(() async {
      final list = await (_database.select(_database.attachments)
            ..where((t) => t.workOrderId.equals(workOrderId) & t.deletedAt.isNull()))
          .get();

      return SuccessState(
        data: list
            .map(
              (t) => AttachmentResponseModel(
                id: t.id,
                workOrderId: t.workOrderId,
                companyId: t.companyId,
                uploadedById: t.uploadedById,
                fileName: t.fileName,
                fileType: FileType.fromCode(t.fileType),
                localPath: t.localPath,
                remoteUrl: t.remoteUrl,
                fileSizeBytes: t.fileSizeBytes,
                isCompressed: t.isCompressed,
                uploadStatus: UploadStatus.fromCode(t.uploadStatus),
                createdAt: t.createdAt,
                deletedAt: t.deletedAt,
              ),
            )
            .toList(),
      );
    });
  }

  @override
  FutureBool saveAttachment(AttachmentResponseModel attachment) {
    return ErrorHandler.execute(() async {
      await _database.into(_database.attachments).insertOnConflictUpdate(
            AttachmentsCompanion(
              id: Value(attachment.id),
              workOrderId: Value(attachment.workOrderId),
              companyId: Value(attachment.companyId),
              uploadedById: Value(attachment.uploadedById),
              fileName: Value(attachment.fileName),
              fileType: Value(attachment.fileType.code),
              localPath: Value(attachment.localPath),
              remoteUrl: Value(attachment.remoteUrl),
              fileSizeBytes: Value(attachment.fileSizeBytes),
              isCompressed: Value(attachment.isCompressed),
              uploadStatus: Value(attachment.uploadStatus.code),
              createdAt: Value(attachment.createdAt),
              deletedAt: Value(attachment.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteAttachment(String id) {
    return ErrorHandler.execute(() async {
      await (_database.update(_database.attachments)
            ..where((t) => t.id.equals(id)))
          .write(AttachmentsCompanion(deletedAt: Value(DateTime.now())));
      return const SuccessState(data: true);
    });
  }
}
