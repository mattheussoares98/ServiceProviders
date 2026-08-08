part of '../create_update_service_provider_company_page.dart';

class _CpfCnpjField extends StatelessWidget {
  const _CpfCnpjField({
    required this.documentType,
    required this.documentController,
    required this.documentFocusNode,
  });

  final ValueNotifier<DocumentType> documentType;
  final TextEditingController documentController;
  final FocusNode documentFocusNode;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      labelText: documentType.value == DocumentType.cpf
          ? 'CPF'.hardcoded
          : 'CNPJ'.hardcoded,
      controller: documentController,
      focusNode: documentFocusNode,
      keyboardType: TextInputType.number,
      maxLength: documentType.value == DocumentType.cpf ? 11 : 14,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      validator: FormValidators.compose([
        CpfCnpjValidator(
          validateOnlyCnpj: documentType.value == DocumentType.cnpj,
          validateOnlyCpf: documentType.value == DocumentType.cpf,
        ),
      ]),
    );
  }
}
