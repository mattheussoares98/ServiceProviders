import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class CustomerContactSection extends StatelessWidget {
  const CustomerContactSection({
    super.key,
    required this.contactNameController,
    required this.contactEmailController,
    required this.contactPhoneController,
    required this.notesController,
  });

  final TextEditingController contactNameController;
  final TextEditingController contactEmailController;
  final TextEditingController contactPhoneController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseText.titleMedium('Contato e Observações'.hardcoded),
        gapH12,
        BaseTextFormField(
          controller: contactNameController,
          labelText: 'Nome do contato'.hardcoded,
        ),
        gapH12,
        Row(
          children: [
            Expanded(
              child: BaseTextFormField(
                controller: contactEmailController,
                labelText: 'E-mail'.hardcoded,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            gapW12,
            Expanded(
              child: BaseTextFormField(
                controller: contactPhoneController,
                labelText: 'Telefone'.hardcoded,
                keyboardType: TextInputType.phone,
                //TODO create phone validator
              ),
            ),
          ],
        ),
        gapH12,
        BaseTextFormField(
          controller: notesController,
          labelText: 'Observações'.hardcoded,
          maxLines: 3,
          maxLength: 300,
        ),
      ],
    );
  }
}
