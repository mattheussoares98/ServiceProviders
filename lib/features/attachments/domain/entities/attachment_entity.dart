import 'package:clean_architecture/features/attachments/domain/entities/file_type.dart';
import 'package:clean_architecture/features/attachments/domain/entities/upload_status.dart';
import 'package:equatable/equatable.dart';

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
  }) {
    return AttachmentEntity(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      companyId: companyId ?? this.companyId,
      uploadedById: uploadedById ?? this.uploadedById,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      isCompressed: isCompressed ?? this.isCompressed,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  AttachmentEntity annulLocalPath() => AttachmentEntity(
        id: id,
        workOrderId: workOrderId,
        companyId: companyId,
        uploadedById: uploadedById,
        fileName: fileName,
        fileType: fileType,
        localPath: null,
        remoteUrl: remoteUrl,
        fileSizeBytes: fileSizeBytes,
        isCompressed: isCompressed,
        uploadStatus: uploadStatus,
        createdAt: createdAt,
        deletedAt: deletedAt,
      );

  AttachmentEntity annulRemoteUrl() => AttachmentEntity(
        id: id,
        workOrderId: workOrderId,
        companyId: companyId,
        uploadedById: uploadedById,
        fileName: fileName,
        fileType: fileType,
        localPath: localPath,
        remoteUrl: null,
        fileSizeBytes: fileSizeBytes,
        isCompressed: isCompressed,
        uploadStatus: uploadStatus,
        createdAt: createdAt,
        deletedAt: deletedAt,
      );

  AttachmentEntity annulFileSizeBytes() => AttachmentEntity(
        id: id,
        workOrderId: workOrderId,
        companyId: companyId,
        uploadedById: uploadedById,
        fileName: fileName,
        fileType: fileType,
        localPath: localPath,
        remoteUrl: remoteUrl,
        fileSizeBytes: null,
        isCompressed: isCompressed,
        uploadStatus: uploadStatus,
        createdAt: createdAt,
        deletedAt: deletedAt,
      );

  AttachmentEntity annulDeletedAt() => AttachmentEntity(
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
        deletedAt: null,
      );
}
