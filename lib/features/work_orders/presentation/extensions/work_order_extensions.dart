import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';

extension PriorityUiExtension on Priority {
  String get label => switch (this) {
    Priority.low => 'Baixa'.hardcoded,
    Priority.medium => 'Média'.hardcoded,
    Priority.high => 'Alta'.hardcoded,
    Priority.critical => 'Crítica'.hardcoded,
  };

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

extension WorkOrderTypeUiExtension on WorkOrderType {
  String get label => switch (this) {
    WorkOrderType.corrective => 'Corretiva'.hardcoded,
    WorkOrderType.preventive => 'Preventiva'.hardcoded,
    WorkOrderType.inspection => 'Inspeção'.hardcoded,
  };

  Color get color => switch (this) {
    WorkOrderType.preventive => Colors.blue,
    WorkOrderType.corrective => Colors.green,
    WorkOrderType.inspection => Colors.orange,
  };
}

extension WorkOrderStatusUiExtension on WorkOrderStatus {
  String get label => switch (this) {
    WorkOrderStatus.open => 'Aberta'.hardcoded,
    WorkOrderStatus.inProgress => 'Em andamento'.hardcoded,
    WorkOrderStatus.onHold => 'Em pausa'.hardcoded,
    WorkOrderStatus.pendingConclusionApproval =>
      'Conclusão pendente de aprovação'.hardcoded,
    WorkOrderStatus.completed => 'Concluída'.hardcoded,
    WorkOrderStatus.cancelled => 'Cancelada'.hardcoded,
  };

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

extension PauseRequestStatusUiExtension on PauseRequestStatus {
  String get label => switch (this) {
    PauseRequestStatus.pending => 'Pendente'.hardcoded,
    PauseRequestStatus.approved => 'Aprovado'.hardcoded,
    PauseRequestStatus.rejected => 'Rejeitado'.hardcoded,
    PauseRequestStatus.cancelled => 'Cancelado'.hardcoded,
  };
}

extension PauseResponsibilityUiExtension on PauseResponsibility {
  String get label => switch (this) {
    PauseResponsibility.provider => 'Prestador'.hardcoded,
    PauseResponsibility.contractor => 'Contratante'.hardcoded,
    PauseResponsibility.shared => 'Compartilhada'.hardcoded,
  };
}
