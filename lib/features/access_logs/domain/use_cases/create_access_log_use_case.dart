import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/create_access_log_request_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/repositories/access_logs_repository.dart';

@LazySingleton()
class CreateAccessLogUseCase
    implements UseCase<void, CreateAccessLogRequestEntity> {
  CreateAccessLogUseCase({required AccessLogsRepository accessLogsRepository})
      : _accessLogsRepository = accessLogsRepository;

  final AccessLogsRepository _accessLogsRepository;

  @override
  FutureVoid call(CreateAccessLogRequestEntity request) =>
      _accessLogsRepository.createAccessLog(request);
}
