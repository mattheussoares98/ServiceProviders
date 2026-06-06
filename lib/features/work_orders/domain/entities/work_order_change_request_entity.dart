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
}
