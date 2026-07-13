import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_image_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

part 'document_preview.dart';
part 'image_preview.dart';
part 'processing_attachment_item.dart';

const double _kAttachmentPreviewHeight = 200;

class AttachmentItem extends StatelessWidget {
  const AttachmentItem({
    super.key,
    required this.attachment,
    required this.isEditing,
  });

  final AttachmentEntity attachment;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    void onDelete() {
      showAlertDialog(
        context: context,
        title: 'Remover anexo'.hardcoded,
        contentText: 'Deseja realmente remover o anexo?'.hardcoded,
        defaultActionText: 'Sim'.hardcoded,
        cancelActionText: 'Não'.hardcoded,
        onOkPressed: () {
          context.read<AttachmentsCubit>().deleteAttachment(attachment.id);
        },
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.p12),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(color: context.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _Preview(attachment: attachment),
          if (isEditing) ...[
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  if (kDebugMode) ...[
                    BaseText('Size showed on debug mode'.hardcoded),
                    BaseText.title(_formatSize(attachment.fileSizeBytes!)),
                  ],
                  InkWell(
                    onTap: onDelete,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface.withValues(
                          alpha: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
                      child: Center(
                        child: FittedBox(
                          child: BaseTextButton(
                            text: 'Remover anexo'.hardcoded,
                            textColor: Colors.redAccent,
                            platformIcon: const PlatformIcon(
                              materialIcon: Icons.delete_outline,
                              cupertinoIcon: CupertinoIcons.trash,
                              color: Colors.redAccent,
                            ),
                            onPressed: onDelete,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.attachment});
  final AttachmentEntity attachment;

  @override
  Widget build(BuildContext context) {
    if (attachment.fileType == FileType.image) {
      return _ImagePreview(attachment: attachment);
    }

    final previewWidget = attachment.fileType == FileType.video
        ? _ImagePreview(attachment: attachment, isPlayable: true)
        : _DocumentPreview(attachment: attachment);

    return InkWell(
      onTap: () => context.read<AttachmentsCubit>().openAttachment(attachment),
      child: previewWidget,
    );
  }
}
