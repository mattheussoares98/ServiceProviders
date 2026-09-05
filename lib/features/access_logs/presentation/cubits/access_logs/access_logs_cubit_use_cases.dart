import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/use_cases/get_access_logs_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_users_use_case.dart';

@LazySingleton()
class AccessLogsCubitUseCases {
  const AccessLogsCubitUseCases({
    required this.getAccessLogs,
    required this.getActiveCompanyId,
    required this.getUsers,
  });

  final GetAccessLogsUseCase getAccessLogs;
  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final GetUsersUseCase getUsers;
}
