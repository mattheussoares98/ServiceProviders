import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/domain/entities/user_invitation_entity.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetPendingInvitationsUseCase implements UseCase<List<UserInvitationEntity>, String> {
  GetPendingInvitationsUseCase({required UsersRepository usersRepository})
      : _usersRepository = usersRepository;

  final UsersRepository _usersRepository;

  @override
  FutureList<UserInvitationEntity> call(String companyId) =>
      _usersRepository.getPendingInvitations(companyId);
}
