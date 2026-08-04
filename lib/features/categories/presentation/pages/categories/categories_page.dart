import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/widgets/open_drawer_icon_button.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

@RoutePage()
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});
  //TODO test this page
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      onRefresh: () => context.read<CategoriesCubit>().loadCategories(),
      isScrollable: false,
      appBar: BaseAppBar(
        title: 'Categorias'.hardcoded,
        leading: const OpenDrawerIconButton(),
        actions: [
          BaseIconButton(
            permission: const ActionPermission.resource(
              resource: ResourceType.categories,
              action: PermissionAction.create,
            ),
            onPressed: () => context
                .read<CategoriesCubit>()
                .navigateToCreateUpdateCategory(),
            platformIcon: const PlatformIcon(
              materialIcon: Icons.add,
              cupertinoIcon: CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body:
          BaseStateView<CategoriesCubit, CategoriesState, List<CategoryEntity>>(
            dataSelector: (state) => state.categories,
            onRetry: () => context.read<CategoriesCubit>().loadCategories(),
            builder: (context, categories) {
              if (categories.isEmpty) {
                return Center(
                  child: BaseText.bodyMedium(
                    'Nenhuma categoria cadastrada'.hardcoded,
                  ),
                );
              }

              return ResponsiveListFlow(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    child: BaseListTile(
                      title: category.name,
                      subtitle: category.description,
                      platformIcon: const PlatformIcon(
                        materialIcon: Icons.list,
                        cupertinoIcon: CupertinoIcons.list_bullet,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BaseIconButton(
                            permission: const ActionPermission.resource(
                              resource: ResourceType.categories,
                              action: PermissionAction.update,
                            ),
                            onPressed: () => context
                                .read<CategoriesCubit>()
                                .navigateToCreateUpdateCategory(
                                  category: category,
                                ),
                            platformIcon: const PlatformIcon(
                              materialIcon: Icons.edit_outlined,
                              cupertinoIcon: CupertinoIcons.pencil,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
