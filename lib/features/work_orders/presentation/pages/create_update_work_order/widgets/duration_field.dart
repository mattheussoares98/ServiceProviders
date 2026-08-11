part of '../create_update_work_order_page.dart';

class _DurationField extends StatelessWidget {
  const _DurationField({
    required this.controller,
    required this.onSubmit,
    required this.descFocusNode,
    required this.enabled,
  });

  final TextEditingController controller;
  final VoidCallback? onSubmit;
  final FocusNode descFocusNode;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      enabled: enabled,
      labelText: 'Duração (min, opcional)'.hardcoded,
      hintText: 'Ex: 60'.hardcoded,
      controller: controller,
      focusNode: descFocusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      onFieldSubmitted: (_) => onSubmit?.call(),
      validator: FormValidators.compose([
        NumberValidator(
          allowDecimal: false,
          allowEmptyValue: true,
          needsBeGreaterThanZero: false,
        ),
      ]),
    );
  }
}
