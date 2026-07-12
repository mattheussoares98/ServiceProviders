part of 'attachment_item.dart';

class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({required this.attachment});
  final AttachmentEntity attachment;

  @override
  Widget build(BuildContext context) {
    final icon = switch (attachment.fileType) {
      FileType.pdf => const PlatformIcon(
        materialIcon: Icons.picture_as_pdf_outlined,
        cupertinoIcon: CupertinoIcons.doc_text,
      ),
      FileType.spreadsheet => const PlatformIcon(
        materialIcon: Icons.table_chart_outlined,
        cupertinoIcon: CupertinoIcons.table,
      ),
      FileType.video => const PlatformIcon(
        materialIcon: Icons.play_circle_outline,
        cupertinoIcon: CupertinoIcons.play_circle,
      ),
      _ => const PlatformIcon(
        materialIcon: Icons.insert_drive_file_outlined,
        cupertinoIcon: CupertinoIcons.doc,
      ),
    };

    final color = switch (attachment.fileType) {
      FileType.pdf => Colors.red[700],
      FileType.spreadsheet => Colors.green[700],
      FileType.video => Colors.blue[700],
      _ => Colors.grey[700],
    };

    return Container(
      height: 120,
      color: color?.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: icon,
    );
  }
}
