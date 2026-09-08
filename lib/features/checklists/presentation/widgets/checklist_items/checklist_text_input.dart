part of '../checklist_item_tile.dart';

/// Widget for Text responses using TextEditingController inside HookWidget
class ChecklistTextInput extends HookWidget {
  const ChecklistTextInput({
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
    final controller = useTextEditingController(
      text: response?.textValue ?? '',
    );
    // Each answer is persisted remotely, so typing must not fire a write per
    // keystroke — settle first, then save.
    final debounce = useMemoized(
      () => DebounceTime(delay: const Duration(milliseconds: 600)),
    );
    useEffect(() => debounce.dispose, [debounce]);

    return BaseTextFormField(
      controller: controller,
      hintText: 'Digite a resposta'.hardcoded,
      onChanged: (val) => debounce.run(() {
        final current =
            response ?? ChecklistAnswerEntity.empty(checklistItemId: item.id);
        onChanged(current.copyWith(textValue: val));
      }),
    );
  }
}
