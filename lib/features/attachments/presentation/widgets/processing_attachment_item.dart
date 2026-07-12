part of 'attachment_item.dart';

class ProcessingAttachmentItem extends StatelessWidget {
  const ProcessingAttachmentItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.p12),
      height: _kAttachmentPreviewHeight,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.4,
        ),
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingCircle(),
          gapH12,
          BaseText.bodySmall(
            'Processando...'.hardcoded,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
