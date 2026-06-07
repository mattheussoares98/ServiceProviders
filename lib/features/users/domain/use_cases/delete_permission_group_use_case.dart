import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class DeletePermissionGroupUseCase
    implements UseCase<bool, String> {
  DeletePermissionGroupUseCase({required UsersRepository usersRepository})
      : _usersRepository = usersRepository;

  final UsersRepository _usersRepository;

  @override
  FutureBool call(String request) =>
      _usersRepository.deletePermissionGroup(request);
}
