import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_metadata_entity.dart';

class AuditMetadataModel extends AuditMetadataEntity
    implements DataConvertible<AuditMetadataEntity> {
  const AuditMetadataModel({
    super.fileName,
    super.fileUrl,
    super.fileType,
    super.fileSizeBytes,
    super.eventType,
    super.reason,
    super.status,
    super.reviewObservation,
  });

  factory AuditMetadataModel.fromEntity(AuditMetadataEntity entity) =>
      AuditMetadataModel(
        fileName: entity.fileName,
        fileUrl: entity.fileUrl,
        fileType: entity.fileType,
        fileSizeBytes: entity.fileSizeBytes,
        eventType: entity.eventType,
        reason: entity.reason,
        status: entity.status,
        reviewObservation: entity.reviewObservation,
      );

  factory AuditMetadataModel.fromJson(MapDynamic json) => AuditMetadataModel(
    fileName: json['file_name'] as String?,
    fileUrl: json['file_url'] as String?,
    fileType: json['file_type'] as String?,
    fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt(),
    eventType: json['event_type'] as String?,
    reason: json['reason'] as String?,
    status: json['status'] as String?,
    reviewObservation: json['review_observation'] as String?,
  );

  @override
  MapDynamic toJson() => {
    'file_name': fileName,
    'file_url': fileUrl,
    'file_type': fileType,
    'file_size_bytes': fileSizeBytes,
    'event_type': eventType,
    'reason': reason,
    'status': status,
    'review_observation': reviewObservation,
  };

  @override
  AuditMetadataEntity toEntity() => AuditMetadataEntity(
    fileName: fileName,
    fileUrl: fileUrl,
    fileType: fileType,
    fileSizeBytes: fileSizeBytes,
    eventType: eventType,
    reason: reason,
    status: status,
    reviewObservation: reviewObservation,
  );
}
