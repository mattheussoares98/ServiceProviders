import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_responsability.dart';

class PauseRequestModel extends PauseRequestEntity
    implements DataConvertible<PauseRequestEntity> {
  const PauseRequestModel({
    required super.id,
    required super.companyId,
    required super.workOrderId,
    super.requestedById,
    super.eventType,
    super.reasonId,
    super.customReason,
    super.observation,
    super.responsibility,
    super.sectorId,
    required super.status,
    required super.pausedAt,
    super.resumedAt,
    super.resumedById,
    super.reviewedById,
    super.reviewObservation,
    required super.affectsSla,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PauseRequestModel.fromEntity(PauseRequestEntity entity) =>
      PauseRequestModel(
        id: entity.id,
        companyId: entity.companyId,
        workOrderId: entity.workOrderId,
        requestedById: entity.requestedById,
        eventType: entity.eventType,
        reasonId: entity.reasonId,
        customReason: entity.customReason,
        observation: entity.observation,
        responsibility: entity.responsibility,
        sectorId: entity.sectorId,
        status: entity.status,
        pausedAt: entity.pausedAt,
        resumedAt: entity.resumedAt,
        resumedById: entity.resumedById,
        reviewedById: entity.reviewedById,
        reviewObservation: entity.reviewObservation,
        affectsSla: entity.affectsSla,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  factory PauseRequestModel.fromJson(MapDynamic json) {
    final now = DateTime.now();
    return PauseRequestModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      workOrderId: json['work_order_id'] as String? ?? '',
      requestedById: json['requested_by_id'] as String?,
      eventType: PauseEventType.fromValue(
        json['event_type'] as String? ?? 'pause',
      ),
      reasonId: json['reason_id'] as String?,
      customReason: json['custom_reason'] as String?,
      observation: json['observation'] as String?,
      responsibility: json['responsibility'] != null
          ? PauseResponsibility.fromValue(json['responsibility'] as String)
          : null,
      sectorId: json['sector_id'] as String?,
      status: PauseRequestStatus.fromValue(json['status'] as String? ?? ''),
      pausedAt: (json['paused_at'] as String?).toUtcDateTime() ?? now,
      resumedAt: (json['resumed_at'] as String?).toUtcDateTime(),
      resumedById: json['resumed_by_id'] as String?,
      reviewedById: json['reviewed_by_id'] as String?,
      reviewObservation: json['review_observation'] as String?,
      affectsSla: json['affects_sla'] as bool? ?? true,
      createdAt: (json['created_at'] as String?).toUtcDateTime() ?? now,
      updatedAt: (json['updated_at'] as String?).toUtcDateTime() ?? now,
    );
  }

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'work_order_id': workOrderId,
    'requested_by_id': requestedById,
    'event_type': eventType.value,
    'reason_id': reasonId,
    'custom_reason': customReason,
    'observation': observation,
    'responsibility': responsibility?.value,
    'sector_id': sectorId,
    'status': status.value,
    'paused_at': pausedAt.toIsoUtcString(),
    'resumed_at': resumedAt?.toIsoUtcString(),
    'resumed_by_id': resumedById,
    'reviewed_by_id': reviewedById,
    'review_observation': reviewObservation,
    'affects_sla': affectsSla,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
  };

  @override
  PauseRequestEntity toEntity() => PauseRequestEntity(
    id: id,
    companyId: companyId,
    workOrderId: workOrderId,
    requestedById: requestedById,
    eventType: eventType,
    reasonId: reasonId,
    customReason: customReason,
    observation: observation,
    responsibility: responsibility,
    sectorId: sectorId,
    status: status,
    pausedAt: pausedAt,
    resumedAt: resumedAt,
    resumedById: resumedById,
    reviewedById: reviewedById,
    reviewObservation: reviewObservation,
    affectsSla: affectsSla,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
