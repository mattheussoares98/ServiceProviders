part of '../checklist_item_tile.dart';

/// Widget for Documentation attachment responses
class ChecklistDocumentationInput extends StatelessWidget {
  const ChecklistDocumentationInput({
    super.key,
    required this.item,
    this.response,
    required this.onChanged,
  });

  final ChecklistItemEntity item;
  final ChecklistAnswerEntity? response;
  final ValueChanged<ChecklistAnswerEntity> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const PlatformIcon(
          materialIcon: Icons.description_outlined,
          cupertinoIcon: CupertinoIcons.doc,
        ),
        gapW8,
        BaseText.bodyMedium(
          response?.photoUrl != null || response?.textValue != null
              ? 'Documento anexado'.hardcoded
              : 'Anexar documento'.hardcoded,
        ),
      ],
    );
  }
}
