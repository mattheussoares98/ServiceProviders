import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/clear_local_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_avatar_use_case.dart';

@LazySingleton()
class HomeCubitUseCases {
  const HomeCubitUseCases({
    required this.logOut,
    required this.clearLocalAttachments,
    required this.getSessionUser,
    required this.pickAttachment,
    required this.updateUserAvatar,
  });

  final LogOutUseCase logOut;
  final ClearLocalAttachmentsUseCase clearLocalAttachments;
  final GetSessionUserUseCase getSessionUser;
  final PickAttachmentUseCase pickAttachment;
  final UpdateUserAvatarUseCase updateUserAvatar;
}
