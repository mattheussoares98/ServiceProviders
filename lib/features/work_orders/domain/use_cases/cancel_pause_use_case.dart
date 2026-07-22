import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';

class CancelPauseParams {
  const CancelPauseParams({
    required this.id,
    required this.resumedAt,
  });

  final String id;
  final DateTime resumedAt;
}

@LazySingleton()
class CancelPauseUseCase implements UseCase<bool, CancelPauseParams> {
  CancelPauseUseCase({required PauseRepository pauseRepository})
      : _pauseRepository = pauseRepository;

  final PauseRepository _pauseRepository;

  @override
  FutureBool call(CancelPauseParams request) => _pauseRepository.cancelPause(
        id: request.id,
        resumedAt: request.resumedAt,
      );
}
