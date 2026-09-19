import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_local_data_source.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_model.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';

import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/maintenance_plan_factory.dart';

void main() {
  late LocalDatabaseFixture fixture;
  AttachmentsLocalDataSourceImpl source() =>
      AttachmentsLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test(
    'upload state and recovery paths persist until an uploaded file is evicted',
    () async {
      final original = MaintenancePlanFactory.makeAttachmentEntity().copyWith(
        localPath: '/test-sandbox/copy.jpg',
        originalPath: '/test-sandbox/original.jpg',
        annulRemoteUrl: true,
        uploadStatus: UploadStatus.pending,
      );
      for (final status in [
        UploadStatus.pending,
        UploadStatus.uploading,
        UploadStatus.failed,
      ]) {
        expect(
          (await source().saveAttachment(
            AttachmentModel.fromEntity(original.copyWith(uploadStatus: status)),
          )).data,
          isTrue,
        );
        await fixture.reopen();
        final row = (await source().getAttachment(original.id)).data!;
        expect(row.uploadStatus, status);
        // FileService resolves this filename inside the current app sandbox.
        expect(row.localPath, 'copy.jpg');
        expect(row.originalPath, original.originalPath);
        expect(row.remoteUrl, isNull);
      }
      final uploaded = original.copyWith(
        uploadStatus: UploadStatus.uploaded,
        remoteUrl: 'https://example.invalid/attachment.jpg',
        annulLocalPath: true,
        annulOriginalPath: true,
      );
      expect(
        (await source().saveAttachment(
          AttachmentModel.fromEntity(uploaded),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final row = (await source().getAttachment(original.id)).data!;
      expect(row.uploadStatus, UploadStatus.uploaded);
      expect(row.localPath, isNull);
      expect(row.originalPath, isNull);
      expect(row.remoteUrl, uploaded.remoteUrl);
    },
  );

  test(
    'attachment replay, removal, and order scoping survive restarts',
    () async {
      final a = MaintenancePlanFactory.makeAttachmentEntity();
      final b = MaintenancePlanFactory.makeAttachmentEntity();
      final batch = [
        AttachmentModel.fromEntity(a),
        AttachmentModel.fromEntity(b),
      ];
      expect((await source().saveAttachments(batch)).data, isTrue);
      await fixture.reopen();
      expect((await source().saveAttachments(batch)).data, isTrue);
      await fixture.reopen();
      expect(
        (await source().getAttachmentsByWorkOrder(
          a.workOrderId,
        )).data!.single.id,
        a.id,
      );
      expect((await source().getAttachmentsByWorkOrderIds([])).data, isEmpty);
      expect((await source().deleteAttachment(a.id)).data, isTrue);
      await fixture.reopen();
      expect(
        (await source().getAttachmentsByWorkOrder(a.workOrderId)).data,
        isEmpty,
      );
      expect((await source().getAttachment(a.id)).data!.deletedAt, isNotNull);
      expect(
        (await source().getAttachmentsByWorkOrder(
          b.workOrderId,
        )).data!.single.id,
        b.id,
      );
      expect((await source().hardDeleteAttachment(a.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getAttachment(a.id)).data, isNull);
    },
  );

  test(
    'cache eviction candidates exclude files still pending or failed after restart',
    () async {
      final uploaded = MaintenancePlanFactory.makeAttachmentEntity().copyWith(
        uploadStatus: UploadStatus.uploaded,
        localPath: '/test-sandbox/uploaded.jpg',
        lastAccessedAt: DateTime.utc(2026, 9, 17),
      );
      final pending = MaintenancePlanFactory.makeAttachmentEntity().copyWith(
        uploadStatus: UploadStatus.pending,
        localPath: '/test-sandbox/pending.jpg',
      );
      final failed = MaintenancePlanFactory.makeAttachmentEntity().copyWith(
        uploadStatus: UploadStatus.failed,
        localPath: '/test-sandbox/failed.jpg',
      );
      expect(
        (await source().saveAttachments(
          [uploaded, pending, failed].map(AttachmentModel.fromEntity).toList(),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().getUploadedOrderedByLastAccess()).data!.map(
          (r) => r.id,
        ),
        [uploaded.id],
      );
      final beforeAccess = DateTime.now().toUtc();
      expect((await source().touchLastAccessed(uploaded.id)).hasError, isFalse);
      await fixture.reopen();
      expect(
        (await source().getAttachment(uploaded.id)).data!.lastAccessedAt!
            .isBefore(beforeAccess.subtract(const Duration(seconds: 1))),
        isFalse,
      );
    },
  );
}
