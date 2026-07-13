import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_response_model.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';

abstract interface class AttachmentsLocalDataSource {
  FutureList<AttachmentResponseModel> getAttachmentsByWorkOrder(
    String workOrderId,
  );
  FutureData<AttachmentResponseModel?> getAttachment(String id);
  FutureBool saveAttachment(AttachmentResponseModel attachment);
  FutureBool deleteAttachment(String id);
  FutureBool hardDeleteAttachment(String id);
  FutureVoid touchLastAccessed(String id);
  FutureData<int> getTotalSandboxBytes();
  FutureList<AttachmentResponseModel> getUploadedOrderedByLastAccess();
}

//TODO create a way to delete automatically older files when they grow more than a limit(for space)
@LazySingleton(as: AttachmentsLocalDataSource)
final class AttachmentsLocalDataSourceImpl
    implements AttachmentsLocalDataSource {
  AttachmentsLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureData<AttachmentResponseModel?> getAttachment(String id) {
    return ErrorHandler.execute(() async {
      final item = await (_database.select(
        _database.attachments,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (item == null) {
        return const SuccessState(data: null);
      }

      return SuccessState(
        data: AttachmentResponseModel(
          id: item.id,
          workOrderId: item.workOrderId,
          companyId: item.companyId,
          uploadedById: item.uploadedById,
          fileName: item.fileName,
          fileType: FileType.fromCode(item.fileType),
          localPath: item.localPath,
          remoteUrl: item.remoteUrl,
          fileSizeBytes: item.fileSizeBytes,
          isCompressed: item.isCompressed,
          uploadStatus: UploadStatus.fromCode(item.uploadStatus),
          createdAt: item.createdAt,
          deletedAt: item.deletedAt,
          originalPath: item.originalPath,
          lastAccessedAt: item.lastAccessedAt,
        ),
      );
    });
  }

  @override
  FutureList<AttachmentResponseModel> getAttachmentsByWorkOrder(
    String workOrderId,
  ) {
    return ErrorHandler.execute(() async {
      final list =
          await (_database.select(_database.attachments)..where(
                (t) => t.workOrderId.equals(workOrderId) & t.deletedAt.isNull(),
              ))
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
                originalPath: t.originalPath,
                lastAccessedAt: t.lastAccessedAt,
              ),
            )
            .toList(),
      );
    });
  }

  @override
  FutureBool saveAttachment(AttachmentResponseModel attachment) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.attachments)
          .insertOnConflictUpdate(
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
              originalPath: Value(attachment.originalPath),
              lastAccessedAt: Value(
                attachment.lastAccessedAt ?? DateTime.now(),
              ),
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

  @override
  FutureBool hardDeleteAttachment(String id) {
    return ErrorHandler.execute(() async {
      await (_database.delete(
        _database.attachments,
      )..where((t) => t.id.equals(id))).go();
      return const SuccessState(data: true);
    });
  }

  @override
  FutureVoid touchLastAccessed(String id) {
    return ErrorHandler.execute(() async {
      await (_database.update(_database.attachments)
            ..where((t) => t.id.equals(id)))
          .write(AttachmentsCompanion(lastAccessedAt: Value(DateTime.now())));
      return SuccessState.nil;
    });
  }

  @override
  FutureData<int> getTotalSandboxBytes() {
    return ErrorHandler.execute(() async {
      final query = _database.selectOnly(_database.attachments)
        ..addColumns([_database.attachments.fileSizeBytes.sum()])
        ..where(
          _database.attachments.localPath.isNotNull() &
              _database.attachments.deletedAt.isNull(),
        );
      final row = await query.getSingle();
      final sum = row.read(_database.attachments.fileSizeBytes.sum()) ?? 0;
      return SuccessState(data: sum);
    });
  }

  @override
  FutureList<AttachmentResponseModel> getUploadedOrderedByLastAccess() {
    return ErrorHandler.execute(() async {
      final list =
          await (_database.select(_database.attachments)
                ..where(
                  (t) =>
                      t.localPath.isNotNull() &
                      t.deletedAt.isNull() &
                      t.uploadStatus.equals(UploadStatus.uploaded.code),
                )
                ..orderBy([(t) => OrderingTerm(expression: t.lastAccessedAt)]))
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
                originalPath: t.originalPath,
                lastAccessedAt: t.lastAccessedAt,
              ),
            )
            .toList(),
      );
    });
  }
}
