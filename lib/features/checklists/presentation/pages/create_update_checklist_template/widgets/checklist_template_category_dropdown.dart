import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

/// Optional category a checklist template applies to.
class ChecklistTemplateCategoryDropdown extends StatelessWidget {
  const ChecklistTemplateCategoryDropdown({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });

  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        final ids = state.categories.map((category) => category.id).toSet();

        return BaseDropDown<String>(
          key: const ValueKey('ChecklistTemplateCategory'),
          showLabelAtTopLeft: true,
          label: 'Categoria'.hardcoded,
          hint: BaseText.bodyMedium('Selecione uma categoria'.hardcoded),
          selectedItem: ids.contains(selectedId) ? selectedId : null,
          items: state.categories
              .map(
                (category) => DropdownMenuItem(
                  value: category.id,
                  child: BaseText(category.name),
                ),
              )
              .toList(),
          onChanged: onChanged,
          onClear: () => onChanged(null),
        );
      },
    );
  }
}
