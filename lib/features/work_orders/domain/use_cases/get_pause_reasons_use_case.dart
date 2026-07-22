import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';

@LazySingleton()
class GetPauseReasonsUseCase implements UseCase<List<PauseReasonEntity>, String> {
  GetPauseReasonsUseCase({required PauseRepository pauseRepository})
      : _pauseRepository = pauseRepository;

  final PauseRepository _pauseRepository;

  @override
  FutureList<PauseReasonEntity> call(String request) =>
      _pauseRepository.getPauseReasons(request);
}
