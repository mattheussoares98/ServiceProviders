import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/invite_user_use_case.dart';

@LazySingleton()
class InviteUserCubitUseCases {
  const InviteUserCubitUseCases({
    required this.getSessionUser,
    required this.inviteUser,
  });

  final GetSessionUserUseCase getSessionUser;
  final InviteUserUseCase inviteUser;
}
