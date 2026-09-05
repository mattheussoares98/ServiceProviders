import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/create_access_log_request_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/get_access_logs_request_entity.dart';

abstract interface class AccessLogsRepository {
  FutureList<AccessLogEntity> getAccessLogs(GetAccessLogsRequestEntity request);
  FutureVoid createAccessLog(CreateAccessLogRequestEntity request);
}
