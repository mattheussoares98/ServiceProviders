import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';

@LazySingleton()
class GetActiveCompanyIdUseCase {
  GetActiveCompanyIdUseCase({
    required SessionRepository sessionRepository,
  }) : _sessionRepository = sessionRepository;

  final SessionRepository _sessionRepository;

  String call() {
    final modeName = _sessionRepository.getSelectedMode();
    final mode = AppMode.fromName(modeName) ?? AppMode.internal;

    if (mode == AppMode.provider) {
      final selectedCompanyId = _sessionRepository.getSelectedCompanyId();
      if (selectedCompanyId != null && selectedCompanyId.isNotEmpty) {
        return selectedCompanyId;
      }
    }

    if (_sessionRepository.userData.user.isSuperAdmin) {
      final selectedCompanyId = _sessionRepository.getSelectedCompanyId();
      if (selectedCompanyId != null && selectedCompanyId.isNotEmpty) {
        return selectedCompanyId;
      }
    }

    return _sessionRepository.userData.user.companyId;
  }
}
