part of '../create_provider_work_order_page.dart';

class _ProviderDescriptionField extends StatelessWidget {
  const _ProviderDescriptionField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      labelText: 'Descrição'.hardcoded,
      controller: controller,
      maxLines: 3,
      textInputAction: TextInputAction.newline,
    );
  }
}
