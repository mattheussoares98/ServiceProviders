import 'package:clean_architecture/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/invite_user_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class InviteUserCubitUseCases {
  const InviteUserCubitUseCases({
    required this.getSessionUser,
    required this.inviteUser,
  });

  final GetSessionUserUseCase getSessionUser;
  final InviteUserUseCase inviteUser;
}
