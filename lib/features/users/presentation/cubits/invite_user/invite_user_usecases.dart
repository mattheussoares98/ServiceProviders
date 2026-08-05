import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/invite_user_use_case.dart';

@LazySingleton()
class InviteUserCubitUseCases {
  const InviteUserCubitUseCases({
    required this.getActiveCompanyId,
    required this.inviteUser,
  });

  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final InviteUserUseCase inviteUser;
}
