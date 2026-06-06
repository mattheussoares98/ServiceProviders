import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetUsersUseCase
    implements UseCase<List<UserProfileEntity>, String> {
  GetUsersUseCase({required UsersRepository usersRepository})
      : _usersRepository = usersRepository;

  final UsersRepository _usersRepository;

  @override
  FutureList<UserProfileEntity> call(String request) =>
      _usersRepository.getUserProfiles(request);
}
