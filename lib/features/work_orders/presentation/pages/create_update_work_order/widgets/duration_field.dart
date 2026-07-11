import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/number_validator.dart';

class DurationField extends StatelessWidget {
  const DurationField({
    super.key,
    required this.durationController,
    required this.durationFocusNode,
    required this.onSubmit,
  });
  final TextEditingController durationController;
  final FocusNode durationFocusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      labelText: 'Duração (min, opcional)'.hardcoded,
      hintText: 'Ex: 60'.hardcoded,
      controller: durationController,
      focusNode: durationFocusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => onSubmit(),
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
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
