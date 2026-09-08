part of '../checklist_item_tile.dart';

/// Document evidence for a `documentation` item.
class ChecklistDocumentationInput extends StatelessWidget {
  const ChecklistDocumentationInput({
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
    return ChecklistEvidenceInput(
      item: item,
      workOrderId: workOrderId,
      response: response,
      sources: const [AttachmentSource.document],
      sourceLabels: ['Escolher arquivo'.hardcoded],
      emptyLabel: 'Anexar documento'.hardcoded,
      attachedLabel: 'Documento anexado'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.description_outlined,
        cupertinoIcon: CupertinoIcons.doc,
      ),
    );
  }
}
