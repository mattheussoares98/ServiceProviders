import 'package:flutter/cupertino.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/email_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

class EmailField extends StatelessWidget {
  const EmailField({super.key, required this.emailController});

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      labelText: 'E-mail'.hardcoded,
      hintText: 'exemplo@email.com'.hardcoded,
      validator: FormValidators.compose([
        NonEmptyValidator(),
        EmailValidator(),
      ]),
    );
  }
}
