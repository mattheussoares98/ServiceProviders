import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:flutter/material.dart';

class DescriptionField extends StatelessWidget {
  const DescriptionField({
    super.key,
    required this.descController,
    required this.descFocusNode,
  });

  final TextEditingController descController;
  final FocusNode descFocusNode;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      labelText: 'Descrição (opcional)'.hardcoded,
      hintText: 'Ex: O equipamento do bloco B não liga'.hardcoded,
      controller: descController,
      focusNode: descFocusNode,
      maxLength: 500,
      maxLines: 3,
      textInputAction: TextInputAction.newline,
    );
  }
}
