import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';

@LazySingleton()
class CheckAuthenticationUseCase
    implements UseCaseSynchronousNoParameter<bool> {
  CheckAuthenticationUseCase({required SessionRepository sessionRepository})
    : _sessionRepository = sessionRepository;
  final SessionRepository _sessionRepository;

  @override
  bool call() => _sessionRepository.isLoggedIn;
}
