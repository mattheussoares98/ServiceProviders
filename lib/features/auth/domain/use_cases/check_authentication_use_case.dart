import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class CheckAuthenticationUseCase
    implements UseCaseSynchronousNoParameter<bool> {
  CheckAuthenticationUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;
  final AuthRepository _authRepository;

  @override
  bool call() => _authRepository.checkAuth();
}
