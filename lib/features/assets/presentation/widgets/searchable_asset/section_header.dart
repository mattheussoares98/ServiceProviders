part of 'searchable_asset_picker_modal.dart';

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Sizes.p16, bottom: Sizes.p8),
      child: Row(
        children: [
          BaseText.titleMedium(title),
          gapW8,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.p8,
              vertical: Sizes.p4,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Sizes.p12),
            ),
            child: BaseText.caption(
              count.toString(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
