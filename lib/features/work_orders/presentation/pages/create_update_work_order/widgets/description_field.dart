part of '../create_update_work_order_page.dart';

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller, this.enabled = true});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      enabled: enabled,
      labelText: 'Descrição (opcional)'.hardcoded,
      hintText: 'Ex: O equipamento do bloco B não liga'.hardcoded,
      controller: controller,
      maxLength: 500,
      maxLines: 10,
      textInputAction: TextInputAction.newline,
    );
  }
}
