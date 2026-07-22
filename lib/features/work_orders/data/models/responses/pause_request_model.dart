import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';

class PauseRequestModel extends PauseRequestEntity
    implements DataConvertible<PauseRequestEntity> {
  const PauseRequestModel({
    required super.id,
    required super.companyId,
    required super.workOrderId,
    super.requestedById,
    super.reasonId,
    super.customReason,
    super.observation,
    required super.responsibility,
    super.sectorId,
    required super.status,
    required super.pausedAt,
    super.resumedAt,
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
        reasonId: entity.reasonId,
        customReason: entity.customReason,
        observation: entity.observation,
        responsibility: entity.responsibility,
        sectorId: entity.sectorId,
        status: entity.status,
        pausedAt: entity.pausedAt,
        resumedAt: entity.resumedAt,
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
      reasonId: json['reason_id'] as String?,
      customReason: json['custom_reason'] as String?,
      observation: json['observation'] as String?,
      responsibility: PauseResponsibility.fromValue(
        json['responsibility'] as String? ?? '',
      ),
      sectorId: json['sector_id'] as String?,
      status: PauseRequestStatus.fromValue(json['status'] as String? ?? ''),
      pausedAt: json['paused_at'] != null
          ? DateTime.parse(json['paused_at'] as String)
          : now,
      resumedAt: json['resumed_at'] != null
          ? DateTime.parse(json['resumed_at'] as String)
          : null,
      reviewedById: json['reviewed_by_id'] as String?,
      reviewObservation: json['review_observation'] as String?,
      affectsSla: json['affects_sla'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : now,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : now,
    );
  }

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'work_order_id': workOrderId,
    'requested_by_id': requestedById,
    'reason_id': reasonId,
    'custom_reason': customReason,
    'observation': observation,
    'responsibility': responsibility.value,
    'sector_id': sectorId,
    'status': status.value,
    'paused_at': pausedAt.toIso8601String(),
    'resumed_at': resumedAt?.toIso8601String(),
    'reviewed_by_id': reviewedById,
    'review_observation': reviewObservation,
    'affects_sla': affectsSla,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  PauseRequestEntity toEntity() => PauseRequestEntity(
    id: id,
    companyId: companyId,
    workOrderId: workOrderId,
    requestedById: requestedById,
    reasonId: reasonId,
    customReason: customReason,
    observation: observation,
    responsibility: responsibility,
    sectorId: sectorId,
    status: status,
    pausedAt: pausedAt,
    resumedAt: resumedAt,
    reviewedById: reviewedById,
    reviewObservation: reviewObservation,
    affectsSla: affectsSla,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
