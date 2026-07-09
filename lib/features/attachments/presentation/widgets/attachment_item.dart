import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_image_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class AttachmentItem extends StatelessWidget {
  const AttachmentItem({
    super.key,
    required this.attachment,
    required this.isUploading,
    required this.onDelete,
    required this.onTap,
  });

  final AttachmentEntity attachment;
  final bool isUploading;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  //TODO improve this widget
  @override
  Widget build(BuildContext context) {
    final showUploadOverlay =
        isUploading || attachment.uploadStatus == UploadStatus.pending;
    final isFailed = attachment.uploadStatus == UploadStatus.failed;

    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.p12),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(
          color: isFailed
              ? AppColors.error.withValues(alpha: 0.5)
              : context.colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Thumbnail
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Preview(attachment: attachment),
                  //TODO move these overlays to the BaseImageWidget
                  if (showUploadOverlay)
                    Container(
                      color: AppColors.black15,
                      child: const Center(
                        child: LoadingCircle(color: Colors.white),
                      ),
                    ),
                  if (isFailed)
                    Container(
                      color: AppColors.error.withValues(alpha: 0.2),
                      child: const Center(
                        child: PlatformIcon(
                          materialIcon: Icons.error_outline,
                          cupertinoIcon: CupertinoIcons.exclamationmark_circle,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info Row
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
                        _StatusIndicator(
                          isUploading: isUploading,
                          uploadStatus: attachment.uploadStatus,
                        ),
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
              onPressed: onDelete,
            ),
          ],
        ),
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

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({
    required this.isUploading,
    required this.uploadStatus,
  });
  final bool isUploading;
  final UploadStatus uploadStatus;

  @override
  Widget build(BuildContext context) {
    if (isUploading) {
      return BaseText.caption(
        'Enviando...'.hardcoded,
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      );
    }

    return switch (uploadStatus) {
      UploadStatus.pending => BaseText.caption(
        'Pendente'.hardcoded,
        color: AppColors.warning,
      ),
      UploadStatus.uploading => BaseText.caption(
        'Enviando...'.hardcoded,
        color: AppColors.primary,
      ),
      UploadStatus.uploaded => BaseText.caption(
        'Enviado'.hardcoded,
        color: AppColors.success,
      ),
      UploadStatus.failed => BaseText.caption(
        'Falhou'.hardcoded,
        color: AppColors.error,
      ),
    };
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
