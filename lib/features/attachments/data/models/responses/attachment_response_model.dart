import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';

class AttachmentResponseModel extends AttachmentEntity
    implements DataConvertible<AttachmentEntity> {
  const AttachmentResponseModel({
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
  });

  factory AttachmentResponseModel.fromEntity(AttachmentEntity entity) =>
      AttachmentResponseModel(
        id: entity.id,
        workOrderId: entity.workOrderId,
        companyId: entity.companyId,
        uploadedById: entity.uploadedById,
        fileName: entity.fileName,
        fileType: entity.fileType,
        localPath: entity.localPath,
        remoteUrl: entity.remoteUrl,
        fileSizeBytes: entity.fileSizeBytes,
        isCompressed: entity.isCompressed,
        uploadStatus: entity.uploadStatus,
        createdAt: entity.createdAt,
        deletedAt: entity.deletedAt,
        originalPath: entity.originalPath,
      );

  factory AttachmentResponseModel.fromJson(MapDynamic json) =>
      AttachmentResponseModel(
        id: json['id'] as String? ?? '',
        workOrderId: json['work_order_id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        uploadedById: json['uploaded_by_id'] as String? ?? '',
        fileName: json['file_name'] as String? ?? '',
        fileType: FileType.fromCode(json['file_type'] as String? ?? 'document'),
        localPath: json['local_path'] as String?,
        remoteUrl: json['remote_url'] as String?,
        fileSizeBytes: json['file_size_bytes'] as int?,
        isCompressed: json['is_compressed'] as bool? ?? false,
        uploadStatus: UploadStatus.fromCode(
          json['upload_status'] as String? ?? 'pending',
        ),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'] as String)
            : null,
        originalPath: json['original_path'] as String?,
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
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
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
  );
}
