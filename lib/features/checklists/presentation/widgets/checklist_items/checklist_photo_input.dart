part of '../checklist_item_tile.dart';

/// Photo evidence for a `photo` item: capture or choose an image, upload it,
/// and store its URL on the answer.
class ChecklistPhotoInput extends StatelessWidget {
  const ChecklistPhotoInput({
    super.key,
    required this.item,
    required this.workOrderId,
    this.response,
    required this.onChanged,
  });

  final ChecklistItemEntity item;
  final String workOrderId;
  final ChecklistAnswerEntity? response;
  final ValueChanged<ChecklistAnswerEntity> onChanged;

  @override
  Widget build(BuildContext context) {
    final isMobile = PlatformUtil.isMobile;

    return ChecklistEvidenceInput(
      item: item,
      workOrderId: workOrderId,
      response: response,
      sources: isMobile
          ? const [AttachmentSource.cameraPhoto, AttachmentSource.gallery]
          : const [AttachmentSource.document],
      sourceLabels: isMobile
          ? ['Tirar foto'.hardcoded, 'Escolher da galeria'.hardcoded]
          : ['Escolher arquivo'.hardcoded],
      allowedExtensions: isMobile ? null : FileExtension.images,
      emptyLabel: 'Anexar foto'.hardcoded,
      attachedLabel: 'Foto anexada'.hardcoded,
      platformIcon: isMobile
          ? const PlatformIcon(
              materialIcon: Icons.camera_alt_outlined,
              cupertinoIcon: CupertinoIcons.camera,
            )
          : const PlatformIcon(
              materialIcon: Icons.photo_library_outlined,
              cupertinoIcon: CupertinoIcons.photo,
            ),
    );
  }
}
