import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:flutter/material.dart';

class FloorField extends StatelessWidget {
  const FloorField({
    super.key,
    required this.floorController,
    required this.floorFocusNode,
    required this.descFocusNode,
  });
  final TextEditingController floorController;
  final FocusNode floorFocusNode;
  final FocusNode descFocusNode;

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      labelText: 'Andar / piso (opcional)'.hardcoded,
      hintText: 'Ex: 2º andar'.hardcoded,
      controller: floorController,
      focusNode: floorFocusNode,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => descFocusNode.requestFocus(),
    );
  }
}
