import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';

@LazySingleton()
class RequestPauseUseCase implements UseCase<bool, PauseRequestEntity> {
  RequestPauseUseCase({required PauseRepository pauseRepository})
      : _pauseRepository = pauseRepository;

  final PauseRepository _pauseRepository;

  @override
  FutureBool call(PauseRequestEntity request) =>
      _pauseRepository.requestPause(request);
}
