import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:clean_architecture/shared_ui/utils/validators/form_validators.dart';
import 'package:clean_architecture/shared_ui/utils/validators/non_empty_validator.dart';
import 'package:flutter/material.dart';

class TitleField extends StatelessWidget {
  const TitleField({
    super.key,
    required this.titleController,
    required this.titleFocusNode,
    required this.descFocusNode,
  });
  final TextEditingController titleController;
  final FocusNode titleFocusNode;
  final FocusNode descFocusNode;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      labelText: 'Título *'.hardcoded,
      hintText: 'Ex: Reparo no ar condicionado'.hardcoded,
      controller: titleController,
      focusNode: titleFocusNode,
      validator: FormValidators.compose([NonEmptyValidator()]),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => descFocusNode.requestFocus(),
    );
  }
}
