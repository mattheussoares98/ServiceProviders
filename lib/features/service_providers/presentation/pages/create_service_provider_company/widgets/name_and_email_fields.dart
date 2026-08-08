part of '../create_update_service_provider_company_page.dart';

class _NameAndEmailFields extends StatelessWidget {
  const _NameAndEmailFields({
    required this.nameController,
    required this.emailController,
    required this.emailFocusNode,
    required this.dddFocusNode,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final FocusNode emailFocusNode;
  final FocusNode dddFocusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BaseTextFormField(
          labelText: 'Nome *'.hardcoded,
          controller: nameController,
          validator: FormValidators.compose([
            NonEmptyValidator(),
            MinLengthValidator(3),
          ]),
          autovalidateMode: AutovalidateMode.onUserInteractionIfError,
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(emailFocusNode),
        ),
        gapH12,
        BaseTextFormField(
          labelText: 'E-mail de contato'.hardcoded,
          controller: emailController,
          focusNode: emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          validator: FormValidators.compose([
            EmailValidator(isRequired: false),
          ]),
          autovalidateMode: AutovalidateMode.onUserInteractionIfError,
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(dddFocusNode),
        ),
      ],
    );
  }
}
