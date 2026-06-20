import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:clean_architecture/shared_ui/utils/validators/form_validators.dart';
import 'package:clean_architecture/shared_ui/utils/validators/non_empty_validator.dart';
import 'package:flutter/material.dart';

class AreaNameField extends StatelessWidget {
  const AreaNameField({
    super.key,
    required this.nameController,
    required this.floorFocusNode,
  });
  final TextEditingController nameController;
  final FocusNode floorFocusNode;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      labelText: 'Nome da área *'.hardcoded,
      hintText: 'Ex: sala de reunião'.hardcoded,
      controller: nameController,
      onFieldSubmitted: (_) => floorFocusNode.requestFocus(),
      validator: FormValidators.compose([NonEmptyValidator()]),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.next,
    );
  }
}
