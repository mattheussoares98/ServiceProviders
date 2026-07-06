import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/users/domain/repositories/users_repository.dart';

@LazySingleton()
class DeleteUserProfileUseCase implements UseCase<bool, String> {
  DeleteUserProfileUseCase({required UsersRepository usersRepository})
    : _usersRepository = usersRepository;

  final UsersRepository _usersRepository;

  @override
  FutureBool call(String request) =>
      _usersRepository.deleteUserProfile(request);
}
