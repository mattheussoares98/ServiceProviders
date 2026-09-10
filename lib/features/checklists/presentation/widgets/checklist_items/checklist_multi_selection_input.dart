part of '../checklist_item_tile.dart';

/// Widget for Multi-Selection checklist responses using BaseCheckbox
class ChecklistMultiSelectionInput extends StatelessWidget {
  const ChecklistMultiSelectionInput({
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
    final options = item.options ?? [];
    final selectedOptions = response?.selectedOptions ?? [];

    void onTap(String opt) {
      final current =
          response ??
          ChecklistAnswerEntity.empty(
            checklistItemId: item.id,
            workOrderId: workOrderId,
          );
      final isChecked = selectedOptions.contains(opt);
      final updated = isChecked
          ? selectedOptions.where((element) => element != opt).toList()
          : [...selectedOptions, opt];
      onChanged(current.copyWith(selectedOptions: updated));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final opt in options) ...[
          Card(
            clipBehavior: .hardEdge,
            child: InkWell(
              onTap: () => onTap(opt),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Sizes.p8,
                  horizontal: Sizes.p8,
                ),
                child: Row(
                  children: [
                    BaseCheckbox(
                      value: selectedOptions.contains(opt),
                      onChanged: (_) => onTap(opt),
                    ),
                    gapW12,
                    Expanded(child: BaseText.bodyMedium(opt)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
