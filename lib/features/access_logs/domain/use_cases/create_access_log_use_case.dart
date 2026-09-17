import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/create_access_log_request_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/repositories/access_logs_repository.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';

@LazySingleton()
class CreateAccessLogUseCase
    implements UseCase<void, CreateAccessLogRequestEntity> {
  CreateAccessLogUseCase({
    required AccessLogsRepository accessLogsRepository,
    required SessionRepository sessionRepository,
  }) : _accessLogsRepository = accessLogsRepository,
       _sessionRepository = sessionRepository;

  final AccessLogsRepository _accessLogsRepository;
  final SessionRepository _sessionRepository;

  @override
  FutureVoid call(CreateAccessLogRequestEntity request) async {
    if (_sessionRepository.userData.user.isSuperAdmin) {
      return SuccessState.nil;
    }
    return await _accessLogsRepository.createAccessLog(request);
  }
}
