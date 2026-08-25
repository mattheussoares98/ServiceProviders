import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart'
    show UploadStatus;

/// The source from which the user picks an attachment.
enum AttachmentSource {
  /// Device camera — single photo.
  cameraPhoto,

  /// Device camera — video recording.
  cameraVideo,

  /// Device gallery — multi-selection of images and videos.
  gallery,

  /// File picker — multi-selection of PDF, DOCX, XLSX.
  document,
}

abstract interface class AttachmentsRepository {
  FutureList<AttachmentEntity> getAttachmentsByWorkOrder(String workOrderId);
  FutureBool createAttachment(AttachmentEntity attachment);
  FutureBool deleteAttachment(String id);

  /// Picks file(s) from [source], validates extension/size, compresses images
  /// and videos, saves each to the local sandbox, and persists them as
  /// [UploadStatus.pending] records.
  ///
  /// If the device is online, immediately uploads each file to R2 and updates
  /// the local record to [UploadStatus.uploaded].
  ///
  /// Returns an empty list when the user cancels the picker without selecting
  /// any file.
  FutureList<AttachmentEntity> pickAndPrepareAttachment({
    required AttachmentSource source,
    required String workOrderId,
    required String companyId,
    required String uploadedById,
    void Function(int count)? onFilesPicked,
    bool multiple = true,
  });

  /// Uploads [attachment] to Cloudflare R2 using the presigned URL handshake,
  /// confirms the upload on the backend, and marks the local record as
  /// [UploadStatus.uploaded].
  FutureBool uploadPendingAttachment(AttachmentEntity attachment);

  /// Touches the lastAccessedAt value for the given attachment [id].
  FutureVoid touchLastAccessed(String id);

  /// Gets the total size in bytes of local sandbox cache files.
  FutureData<int> getSandboxSizeBytes();

  /// Evicts old uploaded attachment files when cache usage exceeds configured limits.
  FutureVoid pruneSandbox();

  /// Clears all local sandbox cache files for uploaded attachments (e.g. on logout).
  FutureVoid clearLocalAttachments();

  /// Subscribes to real-time changes on the attachments table for a specific work order.
  Stream<RealtimeEvent<AttachmentEntity>> watchAttachmentsRealtime({
    required String workOrderId,
  });
}

