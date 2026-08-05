import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/delete_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_sandbox_size_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_video_thumbnail_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/open_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/prune_sandbox_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/touch_last_accessed_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/upload_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';

@LazySingleton()
class AttachmentsCubitUseCases {
  const AttachmentsCubitUseCases({
    required this.getAttachments,
    required this.pickAttachment,
    required this.uploadAttachment,
    required this.deleteAttachment,
    required this.openAttachment,
    required this.getSessionUser,
    required this.getActiveCompanyId,
    required this.getVideoThumbnail,
    required this.pruneSandbox,
    required this.getSandboxSize,
    required this.touchLastAccessed,
  });

  final GetAttachmentsUseCase getAttachments;
  final PickAttachmentUseCase pickAttachment;
  final UploadAttachmentUseCase uploadAttachment;
  final DeleteAttachmentUseCase deleteAttachment;
  final OpenAttachmentUseCase openAttachment;
  final GetSessionUserUseCase getSessionUser;
  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final GetVideoThumbnailUseCase getVideoThumbnail;
  final PruneSandboxUseCase pruneSandbox;
  final GetSandboxSizeUseCase getSandboxSize;
  final TouchLastAccessedUseCase touchLastAccessed;
}
