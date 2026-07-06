import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/invite_user_params.dart';
import 'package:o_jogo_da_obra/features/users/domain/repositories/users_repository.dart';

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
