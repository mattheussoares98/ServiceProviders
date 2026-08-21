part of '../create_provider_work_order_page.dart';

class _ProviderTitleField extends StatelessWidget {
  const _ProviderTitleField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      labelText: 'Título *'.hardcoded,
      hintText: 'Ex: Reparo no ar condicionado'.hardcoded,
      controller: controller,
      validator: FormValidators.compose([NonEmptyValidator()]),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.next,
    );
  }
}
