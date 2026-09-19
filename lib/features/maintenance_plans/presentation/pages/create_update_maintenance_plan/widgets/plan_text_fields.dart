import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

class PlanTextFields extends StatelessWidget {
  const PlanTextFields({
    super.key,
    required this.titleController,
    required this.descController,
    required this.priceController,
    required this.priceFocusNode,
  });

  final TextEditingController titleController;
  final TextEditingController descController;
  final TextEditingController priceController;
  final FocusNode priceFocusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BaseTextFormField(
          labelText: 'Título do plano *'.hardcoded,
          hintText: 'Ex: Manutenção preventiva do gerador'.hardcoded,
          controller: titleController,
          validator: FormValidators.compose([NonEmptyValidator()]),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: TextInputAction.next,
        ),
        gapH16,
        BaseTextFormField(
          labelText: 'Descrição'.hardcoded,
          hintText: 'Descreva os procedimentos a serem executados'.hardcoded,
          controller: descController,
          maxLength: 1000,
          maxLines: 5,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: TextInputAction.next,
        ),
        gapH16,
        BaseTextFormField(
          labelText: r'Valor estimado (R$)'.hardcoded,
          hintText: '0,00'.hardcoded,
          controller: priceController,
          focusNode: priceFocusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}
