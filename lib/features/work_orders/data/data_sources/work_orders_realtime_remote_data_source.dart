import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/realtime_work_order_event.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/realtime_work_order_event_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class WorkOrdersRealtimeRemoteDataSource {
  Stream<RealtimeWorkOrderEvent> watchWorkOrders({String? companyId});
}

@LazySingleton(as: WorkOrdersRealtimeRemoteDataSource)
final class WorkOrdersRealtimeRemoteDataSourceImpl
    implements WorkOrdersRealtimeRemoteDataSource {
  const WorkOrdersRealtimeRemoteDataSourceImpl({
    required SupabaseRealtimeClient realtimeClient,
  }) : _realtimeClient = realtimeClient;

  final SupabaseRealtimeClient _realtimeClient;

  @override
  Stream<RealtimeWorkOrderEvent> watchWorkOrders({String? companyId}) {
    final filter = companyId != null && companyId.isNotEmpty
        ? PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_id',
            value: companyId,
          )
        : null;

    final stream = _realtimeClient.streamTableChanges(
      table: 'work_orders',
      schema: 'public',
      event: PostgresChangeEvent.all,
      filter: filter,
    );

    return stream.map(_mapPayloadToEvent);
  }

  RealtimeWorkOrderEvent _mapPayloadToEvent(PostgresChangePayload payload) {
    final eventType = switch (payload.eventType) {
      PostgresChangeEvent.insert => RealtimeWorkOrderEventType.insert,
      PostgresChangeEvent.update => RealtimeWorkOrderEventType.update,
      PostgresChangeEvent.delete => RealtimeWorkOrderEventType.delete,
      _ => RealtimeWorkOrderEventType.update,
    };

    final record = payload.newRecord.isNotEmpty
        ? payload.newRecord
        : payload.oldRecord;

    final workOrderId = (record['id'] as String?) ?? '';
    final companyId = record['company_id'] as String?;

    WorkOrderModel? workOrder;
    if (payload.newRecord.isNotEmpty) {
      try {
        workOrder = WorkOrderModel.fromJson(MapDynamic.from(payload.newRecord));
      } catch (_) {
        workOrder = null;
      }
    }

    return RealtimeWorkOrderEvent(
      eventType: eventType,
      workOrderId: workOrderId,
      companyId: companyId,
      workOrder: workOrder,
    );
  }
}
