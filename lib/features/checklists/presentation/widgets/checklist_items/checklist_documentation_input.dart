part of '../checklist_item_tile.dart';

/// Document evidence for a `documentation` item.
class ChecklistDocumentationInput extends StatelessWidget {
  const ChecklistDocumentationInput({
    super.key,
    required this.item,
    required this.workOrderId,
    required this.companyId,
    this.response,
    required this.onChanged,
  });

  final ChecklistItemEntity item;
  final String workOrderId;
  final String companyId;
  final ChecklistAnswerEntity? response;
  final ValueChanged<ChecklistAnswerEntity> onChanged;

  @override
  Widget build(BuildContext context) {
    return ChecklistEvidenceInput(
      item: item,
      workOrderId: workOrderId,
      companyId: companyId,
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
