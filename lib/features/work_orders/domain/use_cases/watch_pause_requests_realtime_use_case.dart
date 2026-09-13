import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';

@LazySingleton()
class WatchPauseRequestsRealtimeUseCase {
  const WatchPauseRequestsRealtimeUseCase({
    required PauseRepository pauseRepository,
  }) : _pauseRepository = pauseRepository;

  final PauseRepository _pauseRepository;

  Stream<RealtimeEvent<PauseRequestEntity>> call({
    String? companyId,
    String? workOrderId,
  }) => _pauseRepository.watchPauseRequestsRealtime(
    companyId: companyId,
    workOrderId: workOrderId,
  );
}
