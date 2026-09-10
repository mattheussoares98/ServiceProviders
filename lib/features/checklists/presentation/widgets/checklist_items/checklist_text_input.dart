part of '../checklist_item_tile.dart';

/// Widget for Text responses using TextEditingController inside HookWidget
class ChecklistTextInput extends HookWidget {
  const ChecklistTextInput({
    super.key,
    required this.item,
    required this.workOrderId,
    this.response,
    required this.onChanged,
    required this.formKey,
  });

  final ChecklistItemEntity item;
  final String workOrderId;
  final ChecklistAnswerEntity? response;
  final ValueChanged<ChecklistAnswerEntity> onChanged;
  final GlobalKey<FormState> formKey;

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
      autovalidateMode: .onUserInteractionIfError,
      validator: FormValidators.compose([
        if (item.isRequired) MinLengthValidator(3),
      ]),
      onChanged: (val) => debounce.run(() {
        if (formKey.currentState?.validate() != true) {
          return;
        }
        final current =
            response ??
            ChecklistAnswerEntity.empty(
              checklistItemId: item.id,
              workOrderId: workOrderId,
            );
        onChanged(current.copyWith(textValue: val));
      }),
    );
  }
}
