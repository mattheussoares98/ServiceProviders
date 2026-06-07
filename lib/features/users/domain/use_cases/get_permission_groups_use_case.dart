import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetPermissionGroupsUseCase
    implements UseCase<List<PermissionGroupEntity>, String> {
  GetPermissionGroupsUseCase({required UsersRepository usersRepository})
      : _usersRepository = usersRepository;

  final UsersRepository _usersRepository;

  @override
  FutureList<PermissionGroupEntity> call(String request) =>
      _usersRepository.getPermissionGroups(request);
}
