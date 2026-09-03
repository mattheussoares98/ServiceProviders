import 'package:equatable/equatable.dart';

class AuditMetadataEntity extends Equatable {
  const AuditMetadataEntity({
    this.fileName,
    this.fileUrl,
    this.fileType,
    this.fileSizeBytes,
    this.eventType,
    this.reason,
    this.status,
    this.reviewObservation,
  });

  final String? fileName;
  final String? fileUrl;
  final String? fileType;
  final int? fileSizeBytes;
  final String? eventType;
  final String? reason;
  final String? status;
  final String? reviewObservation;

  @override
  List<Object?> get props => [
    fileName,
    fileUrl,
    fileType,
    fileSizeBytes,
    eventType,
    reason,
    status,
    reviewObservation,
  ];

  AuditMetadataEntity copyWith({
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSizeBytes,
    String? eventType,
    String? reason,
    String? status,
    String? reviewObservation,
    bool? annulFileName,
    bool? annulFileUrl,
    bool? annulFileType,
    bool? annulFileSizeBytes,
    bool? annulEventType,
    bool? annulReason,
    bool? annulStatus,
    bool? annulReviewObservation,
  }) {
    return AuditMetadataEntity(
      fileName: annulFileName == true ? null : fileName ?? this.fileName,
      fileUrl: annulFileUrl == true ? null : fileUrl ?? this.fileUrl,
      fileType: annulFileType == true ? null : fileType ?? this.fileType,
      fileSizeBytes:
          annulFileSizeBytes == true ? null : fileSizeBytes ?? this.fileSizeBytes,
      eventType: annulEventType == true ? null : eventType ?? this.eventType,
      reason: annulReason == true ? null : reason ?? this.reason,
      status: annulStatus == true ? null : status ?? this.status,
      reviewObservation: annulReviewObservation == true
          ? null
          : reviewObservation ?? this.reviewObservation,
    );
  }
}
