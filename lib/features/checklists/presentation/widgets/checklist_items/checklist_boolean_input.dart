part of '../checklist_item_tile.dart';

/// Widget for Boolean (Conformity) responses using BaseChoiceChip
class ChecklistBooleanInput extends StatelessWidget {
  const ChecklistBooleanInput({
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
    final currentVal = response?.booleanValue;

    return BaseChoiceChip<bool>(
      items: const [true, false],
      selections: [?currentVal],
      itemLabelBuilder: (val) =>
          val ? 'Conforme'.hardcoded : 'Não conforme'.hardcoded,
      itemColorBuilder: (val) => val ? Colors.green : Colors.red,
      onChanged: (selectedVal) {
        final current =
            response ?? ChecklistAnswerEntity.empty(checklistItemId: item.id);
        onChanged(current.copyWith(booleanValue: selectedVal));
      },
    );
  }
}
