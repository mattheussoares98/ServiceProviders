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
}
