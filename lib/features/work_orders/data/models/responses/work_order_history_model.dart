import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';

class WorkOrderHistoryModel extends WorkOrderHistoryEntity
    implements DataConvertible<WorkOrderHistoryEntity> {
  const WorkOrderHistoryModel({
    required super.id,
    required super.workOrderId,
    required super.companyId,
    required super.userId,
    required super.action,
    super.oldValue,
    super.newValue,
    required super.createdAt,
  });

  factory WorkOrderHistoryModel.fromEntity(WorkOrderHistoryEntity entity) =>
      WorkOrderHistoryModel(
        id: entity.id,
        workOrderId: entity.workOrderId,
        companyId: entity.companyId,
        userId: entity.userId,
        action: entity.action,
        oldValue: entity.oldValue,
        newValue: entity.newValue,
        createdAt: entity.createdAt,
      );

  factory WorkOrderHistoryModel.fromJson(MapDynamic json) =>
      WorkOrderHistoryModel(
        id: json['id'] as String? ?? '',
        workOrderId: json['work_order_id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        action: json['action'] as String? ?? '',
        oldValue: json['old_value'] as String?,
        newValue: json['new_value'] as String?,
        createdAt: (json['created_at'] as String?).toUtcDateTime() ??
            DateTime.now().toUtc(),
      );

  @override
  MapDynamic toJson() => {
    'id': id,
    'work_order_id': workOrderId,
    'company_id': companyId,
    'user_id': userId,
    'action': action,
    'old_value': oldValue,
    'new_value': newValue,
    'created_at': createdAt.toIsoUtcString(),
  };

  @override
  WorkOrderHistoryEntity toEntity() => WorkOrderHistoryEntity(
    id: id,
    workOrderId: workOrderId,
    companyId: companyId,
    userId: userId,
    action: action,
    oldValue: oldValue,
    newValue: newValue,
    createdAt: createdAt,
  );
}
