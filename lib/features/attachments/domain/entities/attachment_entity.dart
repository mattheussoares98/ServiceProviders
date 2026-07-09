import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';

class AttachmentEntity extends Equatable {
  const AttachmentEntity({
    required this.id,
    required this.workOrderId,
    required this.companyId,
    required this.uploadedById,
    required this.fileName,
    required this.fileType,
    this.localPath,
    this.remoteUrl,
    this.fileSizeBytes,
    required this.isCompressed,
    required this.uploadStatus,
    required this.createdAt,
    this.deletedAt,
    this.originalPath,
  });

  final String id;
  final String workOrderId;
  final String companyId;
  final String uploadedById;
  final String fileName;
  final FileType fileType;
  final String? localPath;
  final String? remoteUrl;
  final int? fileSizeBytes;
  final bool isCompressed;
  final UploadStatus uploadStatus;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final String? originalPath;

  @override
  List<Object?> get props => [
    id,
    workOrderId,
    companyId,
    uploadedById,
    fileName,
    fileType,
    localPath,
    remoteUrl,
    fileSizeBytes,
    isCompressed,
    uploadStatus,
    createdAt,
    deletedAt,
    originalPath,
  ];

  AttachmentEntity copyWith({
    String? id,
    String? workOrderId,
    String? companyId,
    String? uploadedById,
    String? fileName,
    FileType? fileType,
    String? localPath,
    String? remoteUrl,
    int? fileSizeBytes,
    bool? isCompressed,
    UploadStatus? uploadStatus,
    DateTime? createdAt,
    DateTime? deletedAt,
    String? originalPath,
    bool? annulLocalPath,
    bool? annulRemoteUrl,
    bool? annulFileSizeBytes,
    bool? annulDeletedAt,
    bool? annulOriginalPath,
  }) {
    return AttachmentEntity(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      companyId: companyId ?? this.companyId,
      uploadedById: uploadedById ?? this.uploadedById,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      localPath: annulLocalPath == true ? null : localPath ?? this.localPath,
      remoteUrl: annulRemoteUrl == true ? null : remoteUrl ?? this.remoteUrl,
      fileSizeBytes: annulFileSizeBytes == true
          ? null
          : fileSizeBytes ?? this.fileSizeBytes,
      isCompressed: isCompressed ?? this.isCompressed,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
      originalPath: annulOriginalPath == true ? null : originalPath ?? this.originalPath,
    );
  }
}
