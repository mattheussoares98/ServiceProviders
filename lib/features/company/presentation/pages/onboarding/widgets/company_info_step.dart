import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/onboarding/onboarding_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/cpf_cnpj_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

class CompanyInfoStep extends HookWidget {
  const CompanyInfoStep({
    super.key,
    required this.cubit,
    required this.initialName,
    String? initialDocument,
    String? initialCnpj,
  }) : initialDocument = initialDocument ?? initialCnpj ?? '';

  final OnboardingCubit cubit;
  final String initialName;
  final String initialDocument;
  @Deprecated('Use initialDocument instead')
  String get initialCnpj => initialDocument;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(text: initialName);
    final documentController = useTextEditingController(text: initialDocument);
    final documentFocusNode = useFocusNode();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BaseText.title('Dados da sua empresa'.hardcoded),
          gapH8,
          BaseText(
            'Informe o nome da empresa e o CPF ou CNPJ para começar.'.hardcoded,
          ),
          gapH32,
          BaseTextFormField(
            autofocus: true,
            labelText: 'Nome da empresa *'.hardcoded,
            hintText: 'Ex: Construtora Silva'.hardcoded,
            controller: nameController,
            validator: FormValidators.compose([NonEmptyValidator()]),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => documentFocusNode.requestFocus(),
          ),
          gapH20,
          BaseTextFormField(
            focusNode: documentFocusNode,
            labelText: 'CPF ou CNPJ *'.hardcoded,
            hintText: 'Digite o CPF ou CNPJ (somente números)'.hardcoded,
            validator: FormValidators.compose([
              NonEmptyValidator(),
              CpfCnpjValidator(),
            ]),
            controller: documentController,
            keyboardType: TextInputType.number,
            maxLength: 14,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) =>
                _proceed(formKey, nameController, documentController),
          ),
          gapH32,
          BaseButton(
            expandWidth: true,
            text: 'CONTINUAR'.hardcoded,
            onTap: () => _proceed(formKey, nameController, documentController),
          ),
        ],
      ),
    );
  }

  void _proceed(
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController documentController,
  ) {
    if (formKey.currentState?.validate() != true) return;
    FocusManager.instance.primaryFocus?.unfocus();
    cubit
      ..updateCompanyInfo(
        name: nameController.text,
        document: documentController.text,
      )
      ..nextStep();
  }
}
