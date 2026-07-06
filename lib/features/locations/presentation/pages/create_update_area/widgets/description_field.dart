import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';

class DescriptionField extends StatelessWidget {
  const DescriptionField({
    super.key,
    required this.descController,
    required this.descFocusNode,
    required this.submit,
  });

  final TextEditingController descController;
  final FocusNode descFocusNode;
  final VoidCallback submit;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      labelText: 'Descrição (Opcional)'.hardcoded,
      hintText: 'Ex: Sala de reuniões principal'.hardcoded,
      controller: descController,
      focusNode: descFocusNode,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => submit(),
    );
  }
}
