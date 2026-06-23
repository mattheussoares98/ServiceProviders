import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/material.dart';

class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BaseDropDown<String>(
      key: const ValueKey('Category'),
      label: 'Categoria (opcional)'.hardcoded, //TODO implement it
      selectedItem: selectedCategoryId,
      items: [
        DropdownMenuItem<String>(
          value: '',
          child: BaseText('Nenhuma'.hardcoded),
        ),
      ],
      onChanged: onChanged,
      showLabelAtTopLeft: true,
    );
  }
}
