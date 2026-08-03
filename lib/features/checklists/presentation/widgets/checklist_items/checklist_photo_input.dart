part of '../checklist_item_tile.dart';

/// Widget for Photo attachment responses
class ChecklistPhotoInput extends StatelessWidget {
  const ChecklistPhotoInput({
    super.key,
    required this.item,
    this.response,
    required this.onChanged,
  });

  final ChecklistItemEntity item;
  final ChecklistItemResponseEntity? response;
  final ValueChanged<ChecklistItemResponseEntity> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const PlatformIcon(
          materialIcon: Icons.camera_alt_outlined,
          cupertinoIcon: CupertinoIcons.camera,
        ),
        gapW8,
        BaseText.bodyMedium(
          response?.photoUrl != null
              ? 'Foto anexada'.hardcoded
              : 'Anexar foto'.hardcoded,
        ),
      ],
    );
  }
}
