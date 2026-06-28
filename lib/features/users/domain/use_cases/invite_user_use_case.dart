import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/domain/entities/invite_user_params.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class InviteUserUseCase implements UseCase<void, InviteUserParams> {
  InviteUserUseCase({required UsersRepository usersRepository})
    : _usersRepository = usersRepository;

  final UsersRepository _usersRepository;

  @override
  FutureVoid call(InviteUserParams request) => _usersRepository.inviteUser(
    email: request.email,
    companyId: request.companyId,
    groupId: request.groupId,
  );
}
