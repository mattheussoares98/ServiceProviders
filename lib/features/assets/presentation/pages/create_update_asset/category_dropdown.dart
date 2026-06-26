import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:clean_architecture/features/categories/presentation/pages/categories/widgets/create_category_sheet.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/show_modal_page.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final categories = context.select<CategoriesCubit, List<CategoryEntity>>(
      (cubit) => cubit.state.categories,
    );

    return Row(
      children: [
        Expanded(
          child: BaseDropDown<String>(
            key: const ValueKey('Category'),
            label: 'Categoria (opcional)'.hardcoded,
            selectedItem: selectedCategoryId,
            items: [
              DropdownMenuItem<String>(
                value: '',
                child: BaseText('Nenhuma'.hardcoded),
              ),
              ...categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: BaseText(category.name),
                );
              }),
            ],
            onChanged: onChanged,
            showLabelAtTopLeft: true,
          ),
        ),
        gapW8,
        BaseIconButton(
          onPressed: () {
            showModalPage<void>(
              BlocProvider.value(
                value: context.read<CategoriesCubit>(),
                child: const CreateCategorySheet(),
              ),
              context,
            );
          },
          platformIcon: const PlatformIcon(
            materialIcon: Icons.add,
            cupertinoIcon: CupertinoIcons.add,
          ),
        ),
      ],
    );
  }
}
