import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/realtime_work_order_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';

class RealtimeWorkOrderEvent extends Equatable {
  const RealtimeWorkOrderEvent({
    required this.eventType,
    required this.workOrderId,
    this.companyId,
    this.workOrder,
  });

  final RealtimeWorkOrderEventType eventType;
  final String workOrderId;
  final String? companyId;
  final WorkOrderEntity? workOrder;

  RealtimeWorkOrderEvent copyWith({
    RealtimeWorkOrderEventType? eventType,
    String? workOrderId,
    String? companyId,
    WorkOrderEntity? workOrder,
    bool? annulCompanyId,
    bool? annulWorkOrder,
  }) {
    return RealtimeWorkOrderEvent(
      eventType: eventType ?? this.eventType,
      workOrderId: workOrderId ?? this.workOrderId,
      companyId: annulCompanyId == true ? null : companyId ?? this.companyId,
      workOrder: annulWorkOrder == true ? null : workOrder ?? this.workOrder,
    );
  }

  @override
  List<Object?> get props => [eventType, workOrderId, companyId, workOrder];
}
