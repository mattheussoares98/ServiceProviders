import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_image_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class AttachmentItem extends StatelessWidget {
  const AttachmentItem({super.key, required this.attachment});

  final AttachmentEntity attachment;

  //TODO improve this widget
  @override
  Widget build(BuildContext context) {
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Preview(attachment: attachment),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.p12),
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .center,
                  children: [
                    BaseText.bodyMedium(attachment.fileName),
                    gapH4,
                    Row(
                      children: [
                        if (attachment.fileSizeBytes != null) ...[
                          BaseText.caption(
                            _formatSize(attachment.fileSizeBytes!),
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          gapW8,
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: context.colorScheme.onSurfaceVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          gapW8,
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            BaseIconButton(
              platformIcon: const PlatformIcon(
                materialIcon: Icons.delete_outline,
                cupertinoIcon: CupertinoIcons.trash,
                color: Colors.redAccent,
              ),
              onPressed: () {
                showAlertDialog(
                  context: context,
                  title: 'Remover anexo'.hardcoded,
                  contentText: 'Deseja realmente remover o anexo?'.hardcoded,
                  defaultActionText: 'Sim'.hardcoded,
                  cancelActionText: 'Não'.hardcoded,
                  onOkPressed: () {
                    context.read<AttachmentsCubit>().deleteAttachment(
                      attachment.id,
                    );
                  },
                );
              },
            ),
          ],
        ),
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
      BaseImageSource? source;
      if (attachment.localPath?.isNotEmpty ?? false) {
        source = BaseImageSource.local(attachment.localPath);
      } else if (attachment.remoteUrl?.isNotEmpty ?? false) {
        source = BaseImageSource.network(attachment.remoteUrl);
      }
      if (source != null) {
        return BaseImageWidget(
          source: source,
          enableFullScreenOnTap: true,
          heroTag: source.hashCode.toString(),
          height: Sizes.p120,
          width: Sizes.p120,
        );
      }
    }

    final icon = switch (attachment.fileType) {
      FileType.pdf => Icons.picture_as_pdf_outlined,
      FileType.spreadsheet => Icons.table_chart_outlined,
      FileType.video => Icons.play_circle_outline,
      _ => Icons.insert_drive_file_outlined,
    };

    final color = switch (attachment.fileType) {
      FileType.pdf => Colors.red[700],
      FileType.spreadsheet => Colors.green[700],
      FileType.video => Colors.blue[700],
      _ => Colors.grey[700],
    };

    return Container(
      color: color?.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
