part of '../checklist_item_tile.dart';

/// Widget for Numeric responses using TextEditingController inside HookWidget
class ChecklistNumberInput extends HookWidget {
  const ChecklistNumberInput({
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
    final initialText = response?.numberValue != null
        ? response!.numberValue.toString()
        : '';
    final controller = useTextEditingController(
      text: initialText.toBRL(3, true),
    );
    final focusNode = useFocusNode();
    final debounce = useMemoized(
      () => DebounceTime(delay: const Duration(milliseconds: 600)),
    );
    useEffect(() => debounce.dispose, [debounce]);

    return BaseTextFormField(
      controller: controller,
      hintText: 'Digite um número'.hardcoded,
      keyboardType: TextInputType.number,
      focusNode: focusNode,
      autovalidateMode: .onUserInteractionIfError,
      onChanged: (val) => debounce.run(() {
        formKey.currentState?.validate();

        final numVal = val.toDouble();
        final current =
            response ??
            ChecklistAnswerEntity.empty(
              checklistItemId: item.id,
              workOrderId: workOrderId,
            );
        onChanged(
          current.copyWith(
            numberValue: numVal,
            annulNumberValue: numVal == null,
          ),
        );
      }),
    );
  }
}
