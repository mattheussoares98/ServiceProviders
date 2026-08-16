import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';

extension PriorityUiExtension on Priority {
  Color get color {
    switch (this) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.blue;
      case Priority.high:
        return Colors.orange;
      case Priority.critical:
        return Colors.red;
    }
  }
}

extension WorkOrderTypeExtension on WorkOrderType {
  Color get color => switch (this) {
    WorkOrderType.preventive => Colors.blue,
    WorkOrderType.corrective => Colors.green,
    WorkOrderType.inspection => Colors.orange,
  };
}

extension WorkOrderStatusUiExtension on WorkOrderStatus {
  Color get color {
    switch (this) {
      case WorkOrderStatus.open:
        return Colors.grey;
      case WorkOrderStatus.inProgress:
        return Colors.amber;
      case WorkOrderStatus.onHold:
        return Colors.purple;
      case WorkOrderStatus.completed:
        return Colors.green;
      case WorkOrderStatus.cancelled:
        return Colors.red;
      case WorkOrderStatus.pendingConclusionApproval:
        return Colors.lightBlue;
    }
  }
}
