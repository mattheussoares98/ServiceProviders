import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

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
