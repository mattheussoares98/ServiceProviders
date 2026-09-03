import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/work_order_change_type.dart';

class WorkOrderChangeRequestEntity extends Equatable {
  const WorkOrderChangeRequestEntity({
    required this.id,
    required this.workOrderId,
    required this.companyId,
    required this.requestedById,
    required this.changeType,
    required this.changeData,
    required this.status,
    required this.reviewedById,
    required this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String workOrderId;
  final String companyId;
  final String requestedById;
  final WorkOrderChangeType changeType;
  final String changeData;
  final ChangeRequestStatus status;
  final String? reviewedById;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
    id,
    workOrderId,
    companyId,
    requestedById,
    changeType,
    changeData,
    status,
    reviewedById,
    rejectionReason,
    createdAt,
    updatedAt,
    deletedAt,
  ];

  WorkOrderChangeRequestEntity copyWith({
    String? id,
    String? workOrderId,
    String? companyId,
    String? requestedById,
    WorkOrderChangeType? changeType,
    String? changeData,
    ChangeRequestStatus? status,
    String? reviewedById,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulReviewedById,
    bool? annulRejectionReason,
    bool? annulDeletedAt,
  }) {
    return WorkOrderChangeRequestEntity(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      companyId: companyId ?? this.companyId,
      requestedById: requestedById ?? this.requestedById,
      changeType: changeType ?? this.changeType,
      changeData: changeData ?? this.changeData,
      status: status ?? this.status,
      reviewedById: annulReviewedById == true
          ? null
          : reviewedById ?? this.reviewedById,
      rejectionReason: annulRejectionReason == true
          ? null
          : rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
