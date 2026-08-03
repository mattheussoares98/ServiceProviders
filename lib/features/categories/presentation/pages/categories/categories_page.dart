import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/widgets/open_drawer_icon_button.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

@RoutePage()
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

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
            onPressed: () async {
              final result = await context.router.push(
                CreateUpdateCategoryRoute(),
              );
              if (result == true && context.mounted) {
                unawaited(context.read<CategoriesCubit>().loadCategories());
              }
            },
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
                    child: ListTile(
                      title: BaseText.titleMedium(category.name),
                      subtitle: category.description != null
                          ? BaseText.bodySmall(category.description!)
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BaseIconButton(
                            permission: const ActionPermission.resource(
                              resource: ResourceType.categories,
                              action: PermissionAction.update,
                            ),
                            onPressed: () async {
                              final result = await context.router.push(
                                CreateUpdateCategoryRoute(category: category),
                              );
                              if (result == true && context.mounted) {
                                unawaited(
                                  context
                                      .read<CategoriesCubit>()
                                      .loadCategories(),
                                );
                              }
                            },
                            platformIcon: const PlatformIcon(
                              materialIcon: Icons.edit_outlined,
                              cupertinoIcon: CupertinoIcons.pencil,
                            ),
                          ),
                          BaseIconButton(
                            permission: const ActionPermission.resource(
                              resource: ResourceType.categories,
                              action: PermissionAction.delete,
                            ),
                            onPressed: () => context
                                .read<CategoriesCubit>()
                                .deleteCategory(category.id),
                            platformIcon: const PlatformIcon(
                              materialIcon: Icons.delete_outline,
                              cupertinoIcon: CupertinoIcons.trash,
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
