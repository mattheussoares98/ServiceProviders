import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class CreatePermissionGroupUseCase
    implements UseCase<bool, PermissionGroupEntity> {
  CreatePermissionGroupUseCase({required UsersRepository usersRepository})
      : _usersRepository = usersRepository;

  final UsersRepository _usersRepository;

  @override
  FutureBool call(PermissionGroupEntity request) =>
      _usersRepository.createPermissionGroup(request);
}
