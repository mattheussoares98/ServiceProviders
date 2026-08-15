part of '../create_update_work_order_page.dart';

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      labelText: 'Descrição (opcional)'.hardcoded,
      hintText: 'Ex: O equipamento do bloco B não liga'.hardcoded,
      controller: controller,
      maxLength: 500,
      maxLines: 10,
      textInputAction: TextInputAction.newline,
    );
  }
}
