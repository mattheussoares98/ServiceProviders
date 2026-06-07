import 'package:clean_architecture/features/work_orders/domain/entities/change_request_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_type.dart';
import 'package:equatable/equatable.dart';

class WorkOrderChangeRequestEntity extends Equatable {
  const WorkOrderChangeRequestEntity({
    required this.id,
    required this.workOrderId,
    required this.companyId,
    required this.requestedById,
    required this.changeType,
    required this.changeData,
    required this.status,
    this.reviewedById,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
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
  }) {
    return WorkOrderChangeRequestEntity(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      companyId: companyId ?? this.companyId,
      requestedById: requestedById ?? this.requestedById,
      changeType: changeType ?? this.changeType,
      changeData: changeData ?? this.changeData,
      status: status ?? this.status,
      reviewedById: reviewedById ?? this.reviewedById,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  WorkOrderChangeRequestEntity annulReviewedById() => WorkOrderChangeRequestEntity(
        id: id,
        workOrderId: workOrderId,
        companyId: companyId,
        requestedById: requestedById,
        changeType: changeType,
        changeData: changeData,
        status: status,
        reviewedById: null,
        rejectionReason: rejectionReason,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  WorkOrderChangeRequestEntity annulRejectionReason() => WorkOrderChangeRequestEntity(
        id: id,
        workOrderId: workOrderId,
        companyId: companyId,
        requestedById: requestedById,
        changeType: changeType,
        changeData: changeData,
        status: status,
        reviewedById: reviewedById,
        rejectionReason: null,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  WorkOrderChangeRequestEntity annulDeletedAt() => WorkOrderChangeRequestEntity(
        id: id,
        workOrderId: workOrderId,
        companyId: companyId,
        requestedById: requestedById,
        changeType: changeType,
        changeData: changeData,
        status: status,
        reviewedById: reviewedById,
        rejectionReason: rejectionReason,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
      );
}
