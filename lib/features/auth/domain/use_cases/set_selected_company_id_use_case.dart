import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';

@LazySingleton()
class SetSelectedCompanyIdUseCase {
  SetSelectedCompanyIdUseCase({required SessionRepository sessionRepository})
    : _sessionRepository = sessionRepository;

  final SessionRepository _sessionRepository;

  Future<void> call(String? companyId) =>
      _sessionRepository.setSelectedCompanyId(companyId);
}
