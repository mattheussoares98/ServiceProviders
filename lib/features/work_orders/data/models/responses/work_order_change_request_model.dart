import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_type.dart';

class WorkOrderChangeRequestModel extends WorkOrderChangeRequestEntity
    implements DataConvertible<WorkOrderChangeRequestEntity> {
  const WorkOrderChangeRequestModel({
    required super.id,
    required super.workOrderId,
    required super.companyId,
    required super.requestedById,
    required super.changeType,
    required super.changeData,
    required super.status,
    super.reviewedById,
    super.rejectionReason,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory WorkOrderChangeRequestModel.fromEntity(
    WorkOrderChangeRequestEntity entity,
  ) => WorkOrderChangeRequestModel(
    id: entity.id,
    workOrderId: entity.workOrderId,
    companyId: entity.companyId,
    requestedById: entity.requestedById,
    changeType: entity.changeType,
    changeData: entity.changeData,
    status: entity.status,
    reviewedById: entity.reviewedById,
    rejectionReason: entity.rejectionReason,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    deletedAt: entity.deletedAt,
  );

  factory WorkOrderChangeRequestModel.fromJson(MapDynamic json) =>
      WorkOrderChangeRequestModel(
        id: json['id'] as String? ?? '',
        workOrderId: json['work_order_id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        requestedById: json['requested_by_id'] as String? ?? '',
        changeType: WorkOrderChangeType.fromCode(
          json['change_type'] as String? ?? 'update_notes',
        ),
        changeData: json['change_data'] as String? ?? '',
        status: ChangeRequestStatus.fromCode(
          json['status'] as String? ?? 'pending',
        ),
        reviewedById: json['reviewed_by_id'] as String?,
        rejectionReason: json['rejection_reason'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'] as String)
            : null,
      );

  @override
  MapDynamic toJson() => {
    'id': id,
    'work_order_id': workOrderId,
    'company_id': companyId,
    'requested_by_id': requestedById,
    'change_type': changeType.code,
    'change_data': changeData,
    'status': status.code,
    'reviewed_by_id': reviewedById,
    'rejection_reason': rejectionReason,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };

  @override
  WorkOrderChangeRequestEntity toEntity() => WorkOrderChangeRequestEntity(
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
    deletedAt: deletedAt,
  );
}
