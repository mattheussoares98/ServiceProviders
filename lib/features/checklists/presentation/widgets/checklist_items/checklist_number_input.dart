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
  final ChecklistAnswerEntity? response;
  final ValueChanged<ChecklistAnswerEntity> onChanged;

  @override
  Widget build(BuildContext context) {
    final initialText = response?.numberValue != null
        ? response!.numberValue.toString()
        : '';
    final controller = useTextEditingController(text: initialText);
    final debounce = useMemoized(
      () => DebounceTime(delay: const Duration(milliseconds: 600)),
    );
    useEffect(() => debounce.dispose, [debounce]);

    return BaseTextFormField(
      controller: controller,
      hintText: 'Digite um número'.hardcoded,
      keyboardType: TextInputType.number,
      onChanged: (val) => debounce.run(() {
        final numVal = double.tryParse(val);
        final current =
            response ?? ChecklistAnswerEntity.empty(checklistItemId: item.id);
        onChanged(current.copyWith(numberValue: numVal));
      }),
    );
  }
}
