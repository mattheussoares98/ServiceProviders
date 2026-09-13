import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';

@LazySingleton()
class WatchWorkOrderChangeRequestsRealtimeUseCase {
  const WatchWorkOrderChangeRequestsRealtimeUseCase({
    required WorkOrdersRepository workOrdersRepository,
  }) : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  Stream<RealtimeEvent<WorkOrderChangeRequestEntity>> call({
    String? companyId,
  }) => _workOrdersRepository.watchChangeRequestsRealtime(companyId: companyId);
}
