part of '../checklist_item_tile.dart';

/// Widget for Single Selection dropdown responses using BaseDropDown
class ChecklistSelectionInput extends StatelessWidget {
  const ChecklistSelectionInput({
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
    final dropdownItems = options
        .map(
          (opt) => DropdownMenuItem<String>(
            value: opt,
            child: BaseText.bodyMedium(opt),
          ),
        )
        .toList();

    return BaseDropDown<String>(
      label: null,
      hint: BaseText.bodyMedium('Selecione uma opção'.hardcoded),
      items: dropdownItems,
      selectedItem: response?.selectedOption,
      onChanged: (val) {
        final current =
            response ?? ChecklistAnswerEntity.empty(checklistItemId: item.id);
        onChanged(current.copyWith(selectedOption: val));
      },
    );
  }
}
