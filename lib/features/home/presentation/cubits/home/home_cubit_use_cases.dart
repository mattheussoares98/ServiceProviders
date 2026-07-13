import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/clear_local_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/log_out_use_case.dart';

@LazySingleton()
class HomeCubitUseCases {
  const HomeCubitUseCases({
    required this.logOut,
    required this.clearLocalAttachments,
  });

  final LogOutUseCase logOut;
  final ClearLocalAttachmentsUseCase clearLocalAttachments;
}
