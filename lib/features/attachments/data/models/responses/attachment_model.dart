import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:path/path.dart' as p;

class AttachmentModel extends AttachmentEntity
    implements DataConvertible<AttachmentEntity> {
  const AttachmentModel({
    required super.id,
    required super.workOrderId,
    required super.companyId,
    required super.uploadedById,
    required super.fileName,
    required super.fileType,
    super.localPath,
    super.remoteUrl,
    super.fileSizeBytes,
    required super.isCompressed,
    required super.uploadStatus,
    required super.createdAt,
    super.deletedAt,
    super.originalPath,
    super.lastAccessedAt,
  });

  factory AttachmentModel.fromEntity(AttachmentEntity entity) =>
      AttachmentModel(
        id: entity.id,
        workOrderId: entity.workOrderId,
        companyId: entity.companyId,
        uploadedById: entity.uploadedById,
        fileName: entity.fileName,
        fileType: entity.fileType,
        localPath: entity.localPath != null
            ? p.basename(entity.localPath!)
            : null,
        remoteUrl: entity.remoteUrl,
        fileSizeBytes: entity.fileSizeBytes,
        isCompressed: entity.isCompressed,
        uploadStatus: entity.uploadStatus,
        createdAt: entity.createdAt,
        deletedAt: entity.deletedAt,
        originalPath: entity.originalPath,
        lastAccessedAt: entity.lastAccessedAt,
      );

  factory AttachmentModel.fromJson(MapDynamic json) => AttachmentModel(
    id: json['id'] as String? ?? '',
    workOrderId: json['work_order_id'] as String? ?? '',
    companyId: json['company_id'] as String? ?? '',
    uploadedById: json['uploaded_by_id'] as String? ?? '',
    fileName: json['file_name'] as String? ?? '',
    fileType: FileType.fromCode(json['file_type'] as String? ?? 'document'),
    localPath: json['local_path'] != null
        ? p.basename(json['local_path'] as String)
        : null,
    remoteUrl: _sanitizeRemoteUrl(json['remote_url'] as String?),
    fileSizeBytes: json['file_size_bytes'] as int?,
    isCompressed: json['is_compressed'] as bool? ?? false,
    uploadStatus: UploadStatus.fromCode(
      json['upload_status'] as String? ?? 'pending',
    ),
    createdAt: (json['created_at'] as String?).toUtcDateTime() ??
        DateTime.now().toUtc(),
    deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
    originalPath: json['original_path'] as String?,
    lastAccessedAt: (json['last_accessed_at'] as String?).toUtcDateTime(),
  );

  @override
  MapDynamic toJson() => {
    'id': id,
    'work_order_id': workOrderId,
    'company_id': companyId,
    'uploaded_by_id': uploadedById,
    'file_name': fileName,
    'file_type': fileType.code,
    'local_path': localPath,
    'remote_url': remoteUrl,
    'file_size_bytes': fileSizeBytes,
    'is_compressed': isCompressed,
    'upload_status': uploadStatus.code,
    'created_at': createdAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
    'original_path': originalPath,
  };

  @override
  AttachmentEntity toEntity() => AttachmentEntity(
    id: id,
    workOrderId: workOrderId,
    companyId: companyId,
    uploadedById: uploadedById,
    fileName: fileName,
    fileType: fileType,
    localPath: localPath,
    remoteUrl: remoteUrl,
    fileSizeBytes: fileSizeBytes,
    isCompressed: isCompressed,
    uploadStatus: uploadStatus,
    createdAt: createdAt,
    deletedAt: deletedAt,
    originalPath: originalPath,
    lastAccessedAt: lastAccessedAt,
  );
}

String? _sanitizeRemoteUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  final regex = RegExp(
    r'https://([a-f0-9]+)\.r2\.cloudflarestorage\.com/([^/]+)/(.+)',
  );
  final match = regex.firstMatch(url);
  if (match != null) {
    final accountId = match.group(1);
    final key = match.group(3);
    return 'https://pub-$accountId.r2.dev/$key';
  }
  return url;
}
