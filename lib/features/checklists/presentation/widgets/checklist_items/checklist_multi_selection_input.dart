part of '../checklist_item_tile.dart';

/// Widget for Multi-Selection checklist responses using BaseCheckbox
class ChecklistMultiSelectionInput extends StatelessWidget {
  const ChecklistMultiSelectionInput({
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
    final options = item.options ?? [];
    final selectedOptions = response?.selectedOptions ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final opt in options) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Sizes.p8,
              horizontal: Sizes.p4,
            ),
            child: Row(
              children: [
                BaseCheckbox(
                  value: selectedOptions.contains(opt),
                  onChanged: (val) {
                    final current =
                        response ??
                        ChecklistAnswerEntity.empty(checklistItemId: item.id);
                    final isChecked = selectedOptions.contains(opt);
                    final updated = isChecked
                        ? selectedOptions
                              .where((element) => element != opt)
                              .toList()
                        : [...selectedOptions, opt];
                    onChanged(current.copyWith(selectedOptions: updated));
                  },
                ),
                gapW12,
                Expanded(child: BaseText.bodyMedium(opt)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
