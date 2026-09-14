part of '../create_update_work_order_page.dart';

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.onSubmit,
    required this.focusNode,
    required this.enabled,
  });

  final TextEditingController controller;
  final VoidCallback? onSubmit;
  final FocusNode focusNode;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      enabled: enabled,
      labelText: r'Preço (R$, opcional)'.hardcoded,
      hintText: '0,00'.hardcoded,
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      onFieldSubmitted: (_) => onSubmit?.call(),
      validator: FormValidators.compose([
        NumberValidator(
          allowDecimal: true,
          allowEmptyValue: true,
          needsBeGreaterThanZero: false,
        ),
      ]),
    );
  }
}
