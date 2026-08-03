part of '../checklist_item_tile.dart';

/// Widget for Numeric responses using TextEditingController inside HookWidget
class ChecklistNumberInput extends HookWidget {
  const ChecklistNumberInput({
    super.key,
    required this.item,
    this.response,
    required this.onChanged,
  });

  final ChecklistItemEntity item;
  final ChecklistResponseAnswerEntity? response;
  final ValueChanged<ChecklistResponseAnswerEntity> onChanged;

  @override
  Widget build(BuildContext context) {
    final initialText = response?.numberValue != null
        ? response!.numberValue.toString()
        : '';
    final controller = useTextEditingController(text: initialText);

    return BaseTextFormField(
      controller: controller,
      hintText: 'Digite um número'.hardcoded,
      keyboardType: TextInputType.number,
      onChanged: (val) {
        final numVal = double.tryParse(val);
        final current =
            response ??
            ChecklistResponseAnswerEntity.empty(checklistItemId: item.id);
        onChanged(current.copyWith(numberValue: numVal));
      },
    );
  }
}
