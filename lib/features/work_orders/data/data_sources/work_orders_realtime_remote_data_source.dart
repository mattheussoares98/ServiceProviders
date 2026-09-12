import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/realtime_payload_mapper.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class WorkOrdersRealtimeRemoteDataSource {
  Stream<RealtimeEvent<WorkOrderModel>> watchWorkOrders({
    String? companyId,
    String? workOrderId,
  });
}

@LazySingleton(as: WorkOrdersRealtimeRemoteDataSource)
final class WorkOrdersRealtimeRemoteDataSourceImpl
    implements WorkOrdersRealtimeRemoteDataSource {
  const WorkOrdersRealtimeRemoteDataSourceImpl({
    required SupabaseRealtimeClient realtimeClient,
  }) : _realtimeClient = realtimeClient;

  final SupabaseRealtimeClient _realtimeClient;

  @override
  Stream<RealtimeEvent<WorkOrderModel>> watchWorkOrders({
    String? companyId,
    String? workOrderId,
  }) {
    PostgresChangeFilter? filter;
    if (workOrderId != null && workOrderId.isNotEmpty) {
      filter = PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: workOrderId,
      );
    } else if (companyId != null && companyId.isNotEmpty) {
      filter = PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: companyId,
      );
    }

    final stream = _realtimeClient.streamTableChanges(
      table: 'work_orders',
      filter: filter,
    );

    return stream.map(
      (payload) => RealtimePayloadMapper.map(payload, WorkOrderModel.fromJson),
    );
  }
}
