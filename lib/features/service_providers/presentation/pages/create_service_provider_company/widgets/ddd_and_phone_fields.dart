part of '../create_update_service_provider_company_page.dart';

class _DddAndPhoneFields extends StatelessWidget {
  const _DddAndPhoneFields({
    required this.dddController,
    required this.dddFocusNode,
    required this.phoneController,
    required this.phoneFocusNode,
    required this.documentFocusNode,
  });

  final TextEditingController dddController;
  final FocusNode dddFocusNode;
  final TextEditingController phoneController;
  final FocusNode phoneFocusNode;
  final FocusNode documentFocusNode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BaseTextFormField(
            labelText: 'DDD'.hardcoded,
            controller: dddController,
            focusNode: dddFocusNode,
            keyboardType: TextInputType.number,
            maxLength: 2,
            autovalidateMode: AutovalidateMode.onUserInteractionIfError,
            validator: FormValidators.compose([
              NumberValidator(allowDecimal: false, allowEmptyValue: true),
              DddValidator(isRequired: false),
            ]),
            onChanged: (value) {
              final isValid = DddValidator().isValid(value.trim());
              if (isValid) {
                phoneFocusNode.requestFocus();
              }
            },
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(phoneFocusNode),
          ),
        ),
        gapW8,
        Expanded(
          flex: 4,
          child: BaseTextFormField(
            labelText: 'Telefone de contato'.hardcoded,
            controller: phoneController,
            focusNode: phoneFocusNode,
            keyboardType: TextInputType.number,
            maxLength: 9,
            autovalidateMode: AutovalidateMode.onUserInteractionIfError,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(documentFocusNode),
            validator: FormValidators.compose([
              NumberValidator(allowDecimal: false, allowEmptyValue: true),
            ]),
          ),
        ),
      ],
    );
  }
}
