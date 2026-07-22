import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';

class PauseRequestEntity extends Equatable {
  const PauseRequestEntity({
    required this.id,
    required this.companyId,
    required this.workOrderId,
    this.requestedById,
    this.reasonId,
    this.customReason,
    this.observation,
    required this.responsibility,
    this.sectorId,
    required this.status,
    required this.pausedAt,
    this.resumedAt,
    this.reviewedById,
    this.reviewObservation,
    required this.affectsSla,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String workOrderId;
  final String? requestedById;
  final String? reasonId;
  final String? customReason;
  final String? observation;
  final PauseResponsibility responsibility;
  final String? sectorId;
  final PauseRequestStatus status;
  final DateTime pausedAt;
  final DateTime? resumedAt;
  final String? reviewedById;
  final String? reviewObservation;
  final bool affectsSla;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    companyId,
    workOrderId,
    requestedById,
    reasonId,
    customReason,
    observation,
    responsibility,
    sectorId,
    status,
    pausedAt,
    resumedAt,
    reviewedById,
    reviewObservation,
    affectsSla,
    createdAt,
    updatedAt,
  ];

  PauseRequestEntity copyWith({
    String? id,
    String? companyId,
    String? workOrderId,
    String? requestedById,
    String? reasonId,
    String? customReason,
    String? observation,
    PauseResponsibility? responsibility,
    String? sectorId,
    PauseRequestStatus? status,
    DateTime? pausedAt,
    DateTime? resumedAt,
    String? reviewedById,
    String? reviewObservation,
    bool? affectsSla,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? annulRequestedById,
    bool? annulReasonId,
    bool? annulCustomReason,
    bool? annulObservation,
    bool? annulSectorId,
    bool? annulResumedAt,
    bool? annulReviewedById,
    bool? annulReviewObservation,
  }) {
    return PauseRequestEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      workOrderId: workOrderId ?? this.workOrderId,
      requestedById: annulRequestedById == true
          ? null
          : requestedById ?? this.requestedById,
      reasonId: annulReasonId == true ? null : reasonId ?? this.reasonId,
      customReason: annulCustomReason == true ? null : customReason ?? this.customReason,
      observation: annulObservation == true
          ? null
          : observation ?? this.observation,
      responsibility: responsibility ?? this.responsibility,
      sectorId: annulSectorId == true ? null : sectorId ?? this.sectorId,
      status: status ?? this.status,
      pausedAt: pausedAt ?? this.pausedAt,
      resumedAt: annulResumedAt == true ? null : resumedAt ?? this.resumedAt,
      reviewedById: annulReviewedById == true
          ? null
          : reviewedById ?? this.reviewedById,
      reviewObservation: annulReviewObservation == true
          ? null
          : reviewObservation ?? this.reviewObservation,
      affectsSla: affectsSla ?? this.affectsSla,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
