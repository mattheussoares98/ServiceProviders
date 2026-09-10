part of '../checklist_item_tile.dart';

/// Shared body of the `photo` and `documentation` items: shows whether evidence
/// is attached and lets the technician attach or replace it.
///
/// Both types persist into `photoUrl`, so they share one flow and differ only in
/// which [AttachmentSource]s they offer.
class ChecklistEvidenceInput extends HookWidget {
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
    this.allowedExtensions,
  });

  final ChecklistItemEntity item;
  final String workOrderId;
  final ChecklistAnswerEntity? response;
  final List<AttachmentSource> sources;
  final List<String> sourceLabels;
  final String emptyLabel;
  final String attachedLabel;
  final PlatformIcon platformIcon;
  final Set<FileExtension>? allowedExtensions;

  bool get _isPhoto => item.type == ChecklistItemType.photo;
  bool get _hasEvidence => response?.photoUrl?.trim().isNotEmpty == true;

  Future<void> _attach(
    BuildContext context,
    AttachmentSource source,
    ValueNotifier<bool> isUploading,
  ) async {
    final attachmentsCubit = context.read<AttachmentsCubit>();

    isUploading.value = true;
    try {
      final attached = await context
          .read<WorkOrderChecklistCubit>()
          .attachEvidence(
            workOrderId: workOrderId,
            checklistItemId: item.id,
            source: source,
            allowedExtensions: allowedExtensions,
          );

      // The file is a work order attachment as well as the item's evidence, so the
      // attachments section has to pick it up — the upload bypassed its cubit.
      if (attached) await attachmentsCubit.refreshAttachments();
    } finally {
      if (context.mounted) isUploading.value = false;
    }
  }

  String _extractFileName(String raw) {
    final uri = Uri.tryParse(raw);
    final rawName = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : raw.split('/').last;
    try {
      return Uri.decodeComponent(rawName);
    } catch (_) {
      return rawName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isUploading = useState(false);

    Future<void> onAttachTap() async {
      if (isUploading.value) return;

      if (sources.length == 1) {
        return _attach(context, sources.first, isUploading);
      }

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

      if (chosen != null && context.mounted) {
        await _attach(context, chosen, isUploading);
      }
    }

    final evidenceUrl = response?.photoUrl?.trim();

    return Column(
      children: [
        if (_hasEvidence && evidenceUrl != null) ...[
          if (_isPhoto) ...[
            BaseImageWidget(
              source:
                  evidenceUrl.startsWith('http://') ||
                      evidenceUrl.startsWith('https://')
                  ? BaseImageSource.network(evidenceUrl)
                  : BaseImageSource.local(evidenceUrl),
              width: Sizes.p80,
              height: Sizes.p80,
              enableFullScreenOnTap: true,
              heroTag: 'checklist_photo_${item.id}_$evidenceUrl',
            ),
            gapH8,
          ] else ...[
            InkWell(
              onTap: () {
                final attachmentsCubit = context.read<AttachmentsCubit>();
                final matched = attachmentsCubit.state.attachments.where(
                  (a) =>
                      a.remoteUrl == evidenceUrl || a.localPath == evidenceUrl,
                );
                if (matched.isNotEmpty) {
                  attachmentsCubit.openAttachment(matched.first);
                } else {
                  attachmentsCubit.openAttachment(
                    AttachmentEntity.empty(
                      id: item.id,
                      workOrderId: workOrderId,
                      fileName: _extractFileName(evidenceUrl),
                      localPath: evidenceUrl.startsWith('http')
                          ? null
                          : evidenceUrl,
                      remoteUrl: evidenceUrl.startsWith('http')
                          ? evidenceUrl
                          : null,
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(Sizes.p8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.p12,
                  vertical: Sizes.p8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(Sizes.p8),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    platformIcon,
                    gapW8,
                    Expanded(
                      child: BaseText(
                        _extractFileName(evidenceUrl),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    gapW8,
                    const PlatformIcon(
                      materialIcon: Icons.open_in_new,
                      cupertinoIcon: CupertinoIcons.arrow_up_right_square,
                      size: Sizes.p16,
                    ),
                  ],
                ),
              ),
            ),
            gapH8,
          ],
        ],
        InkWell(
          onTap: isUploading.value ? null : onAttachTap,
          borderRadius: BorderRadius.circular(Sizes.p8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
            child: Row(
              children: [
                if (isUploading.value) ...[
                  SizedBox(
                    width: Sizes.p24,
                    height: Sizes.p24,
                    child: LoadingCircle.small(theme.colorScheme.primary),
                  ),
                ] else ...[
                  platformIcon,
                ],
                gapW8,
                Expanded(
                  child: BaseText.bodyMedium(
                    isUploading.value
                        ? 'Enviando...'.hardcoded
                        : (_hasEvidence ? attachedLabel : emptyLabel),
                    color: (_hasEvidence || isUploading.value)
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
                if (_hasEvidence && !isUploading.value)
                  BaseText.caption(
                    'Substituir'.hardcoded,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
