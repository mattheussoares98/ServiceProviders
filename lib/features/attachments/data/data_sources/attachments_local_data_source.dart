import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_model.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';

abstract interface class AttachmentsLocalDataSource {
  FutureList<AttachmentModel> getAttachmentsByWorkOrder(String workOrderId);
  FutureData<AttachmentModel?> getAttachment(String id);
  FutureBool saveAttachment(AttachmentModel attachment);
  FutureBool deleteAttachment(String id);
  FutureBool hardDeleteAttachment(String id);
  FutureVoid touchLastAccessed(String id);
  FutureData<int> getTotalSandboxBytes();
  FutureList<AttachmentModel> getUploadedOrderedByLastAccess();
}

@LazySingleton(as: AttachmentsLocalDataSource)
final class AttachmentsLocalDataSourceImpl
    implements AttachmentsLocalDataSource {
  AttachmentsLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureData<AttachmentModel?> getAttachment(String id) {
    return ErrorHandler.execute(() async {
      final item = await (_database.select(
        _database.attachments,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (item == null) {
        return const SuccessState(data: null);
      }

      return SuccessState(
        data: AttachmentModel(
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
          createdAt: item.createdAt.toUtc(),
          deletedAt: item.deletedAt?.toUtc(),
          originalPath: item.originalPath,
          lastAccessedAt: item.lastAccessedAt?.toUtc(),
        ),
      );
    });
  }

  @override
  FutureList<AttachmentModel> getAttachmentsByWorkOrder(String workOrderId) {
    return ErrorHandler.execute(() async {
      final list =
          await (_database.select(_database.attachments)..where(
                (t) => t.workOrderId.equals(workOrderId) & t.deletedAt.isNull(),
              ))
              .get();

      return SuccessState(
        data: list
            .map(
              (t) => AttachmentModel(
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
                createdAt: t.createdAt.toUtc(),
                deletedAt: t.deletedAt?.toUtc(),
                originalPath: t.originalPath,
                lastAccessedAt: t.lastAccessedAt?.toUtc(),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  FutureBool saveAttachment(AttachmentModel attachment) {
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
              lastAccessedAt: Value(attachment.lastAccessedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteAttachment(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.attachments)
        ..where((t) => t.id.equals(id));
      await query.write(AttachmentsCompanion(deletedAt: Value(DateTime.now())));
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool hardDeleteAttachment(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.delete(_database.attachments)
        ..where((t) => t.id.equals(id));
      await query.go();
      return const SuccessState(data: true);
    });
  }

  @override
  FutureVoid touchLastAccessed(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.attachments)
        ..where((t) => t.id.equals(id));
      await query.write(
        AttachmentsCompanion(lastAccessedAt: Value(DateTime.now())),
      );
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

      final result = await query.getSingle();
      final total = result.read(_database.attachments.fileSizeBytes.sum()) ?? 0;
      return SuccessState(data: total);
    });
  }

  @override
  FutureList<AttachmentModel> getUploadedOrderedByLastAccess() {
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
              (t) => AttachmentModel(
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
                createdAt: t.createdAt.toUtc(),
                deletedAt: t.deletedAt?.toUtc(),
                originalPath: t.originalPath,
                lastAccessedAt: t.lastAccessedAt?.toUtc(),
              ),
            )
            .toList(),
      );
    });
  }
}
