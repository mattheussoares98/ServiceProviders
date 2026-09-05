import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/get_access_logs_request_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/repositories/access_logs_repository.dart';

@LazySingleton()
class GetAccessLogsUseCase
    implements UseCase<List<AccessLogEntity>, GetAccessLogsRequestEntity> {
  GetAccessLogsUseCase({required AccessLogsRepository accessLogsRepository})
      : _accessLogsRepository = accessLogsRepository;

  final AccessLogsRepository _accessLogsRepository;

  @override
  FutureList<AccessLogEntity> call(GetAccessLogsRequestEntity request) =>
      _accessLogsRepository.getAccessLogs(request);
}
