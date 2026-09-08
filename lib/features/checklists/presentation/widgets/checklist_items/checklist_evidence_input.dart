part of '../checklist_item_tile.dart';

/// Shared body of the `photo` and `documentation` items: shows whether evidence
/// is attached and lets the technician attach or replace it.
///
/// Both types persist into `photoUrl`, so they share one flow and differ only in
/// which [AttachmentSource]s they offer.
class ChecklistEvidenceInput extends StatelessWidget {
  const ChecklistEvidenceInput({
    super.key,
    required this.item,
    required this.workOrderId,
    required this.sources,
    required this.sourceLabels,
    required this.emptyLabel,
    required this.attachedLabel,
    required this.platformIcon,
    this.response,
  });

  final ChecklistItemEntity item;
  final String workOrderId;
  final ChecklistAnswerEntity? response;
  final List<AttachmentSource> sources;
  final List<String> sourceLabels;
  final String emptyLabel;
  final String attachedLabel;
  final PlatformIcon platformIcon;

  bool get _hasEvidence => response?.photoUrl?.trim().isNotEmpty == true;

  Future<void> _attach(BuildContext context, AttachmentSource source) async {
    final attachmentsCubit = context.read<AttachmentsCubit>();

    final attached = await context
        .read<WorkOrderChecklistCubit>()
        .attachEvidence(
          workOrderId: workOrderId,
          checklistItemId: item.id,
          source: source,
        );

    // The file is a work order attachment as well as the item's evidence, so the
    // attachments section has to pick it up — the upload bypassed its cubit.
    if (attached) await attachmentsCubit.refreshAttachments();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    Future<void> onTap() async {
      if (sources.length == 1) return _attach(context, sources.first);

      final chosen = await showModalBottomSheet<AttachmentSource>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < sources.length; index++)
                ListTile(
                  leading: platformIcon,
                  title: BaseText.bodyMedium(sourceLabels[index]),
                  onTap: () => Navigator.of(sheetContext).pop(sources[index]),
                ),
            ],
          ),
        ),
      );

      if (chosen != null && context.mounted) await _attach(context, chosen);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Sizes.p8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
        child: Row(
          children: [
            platformIcon,
            gapW8,
            Expanded(
              child: BaseText.bodyMedium(
                _hasEvidence ? attachedLabel : emptyLabel,
                color: _hasEvidence ? theme.colorScheme.primary : null,
              ),
            ),
            if (_hasEvidence)
              BaseText.caption(
                'Substituir'.hardcoded,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
