import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_action.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/create_access_log_request_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/use_cases/create_access_log_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';

@LazySingleton()
class LogOutUseCase {
  LogOutUseCase(
    this._sessionRepository,
    this._createAccessLog,
    this._getActiveCompanyId,
  );
  final SessionRepository _sessionRepository;
  final CreateAccessLogUseCase _createAccessLog;
  final GetActiveCompanyIdUseCase _getActiveCompanyId;

  Future<void> call() async {
    final user = _sessionRepository.userData.user;
    final companyId = _getActiveCompanyId.call();
    final isLoggedIn = _sessionRepository.isLoggedIn;
    if (isLoggedIn && user.id.isNotEmpty && companyId.isNotEmpty) {
      await _createAccessLog.call(
        CreateAccessLogRequestEntity(
          companyId: companyId,
          userId: user.id,
          action: AccessLogAction.logout,
        ),
      );
    }
    await _sessionRepository.logout();
  }
}
