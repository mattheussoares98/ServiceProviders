import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';

@LazySingleton()
class WatchPauseReasonsRealtimeUseCase {
  const WatchPauseReasonsRealtimeUseCase({
    required PauseRepository pauseRepository,
  }) : _pauseRepository = pauseRepository;

  final PauseRepository _pauseRepository;

  Stream<RealtimeEvent<PauseReasonEntity>> call({String? companyId}) =>
      _pauseRepository.watchPauseReasonsRealtime(companyId: companyId);
}
