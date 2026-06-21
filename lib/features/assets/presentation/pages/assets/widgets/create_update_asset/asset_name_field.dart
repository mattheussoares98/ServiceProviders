import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:clean_architecture/shared_ui/utils/validators/form_validators.dart';
import 'package:clean_architecture/shared_ui/utils/validators/non_empty_validator.dart';
import 'package:flutter/cupertino.dart';

class AssetNameField extends StatelessWidget {
  const AssetNameField({
    super.key,
    required this.nameController,
    required this.nameFocusNode,
    required this.codeFocusNode,
  });
  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  final FocusNode codeFocusNode;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      labelText: 'Nome do equipamento *'.hardcoded,
      hintText: 'Ex: Ar condicionado'.hardcoded,
      controller: nameController,
      focusNode: nameFocusNode,
      validator: FormValidators.compose([NonEmptyValidator()]),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => codeFocusNode.requestFocus(),
    );
  }
}
