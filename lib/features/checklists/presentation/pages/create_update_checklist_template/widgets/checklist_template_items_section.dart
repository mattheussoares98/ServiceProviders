import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/pages/create_update_checklist_template/widgets/checklist_template_item_tile.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

/// Lists and manages the items that make up a checklist template.
class ChecklistTemplateItemsSection extends StatelessWidget {
  const ChecklistTemplateItemsSection({super.key, required this.templateId});

  final String templateId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: BaseText.title('Itens do checklist'.hardcoded)),
            BaseIconButton(
              permission: const ActionPermission.resource(
                resourceType: ResourceType.checklists,
                permissionAction: PermissionAction.create,
              ),
              onPressed: () => context
                  .read<ChecklistTemplatesCubit>()
                  .navigateToCreateUpdateItem(templateId: templateId),
              platformIcon: const PlatformIcon(
                materialIcon: Icons.add,
                cupertinoIcon: CupertinoIcons.add,
              ),
            ),
          ],
        ),
        gapH8,
        BaseStateView<
          ChecklistTemplatesCubit,
          ChecklistTemplatesState,
          List<ChecklistItemEntity>
        >(
          sectionKey: ChecklistTemplatesSections.loadItems,
          dataSelector: (state) => state.templateItems,
          onRetry: () => context
              .read<ChecklistTemplatesCubit>()
              .loadItemsByTemplate(templateId),
          builder: (context, items) {
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: Sizes.p16),
                child: BaseText.bodyMedium(
                  'Nenhum item cadastrado neste checklist'.hardcoded,
                ),
              );
            }

            final sorted = [...items]
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

            return ReorderableListView.builder(
              shrinkWrap: true,
              // The page already scrolls; this list only lays itself out.
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: sorted.length,
              onReorderItem: (oldIndex, newIndex) => context
                  .read<ChecklistTemplatesCubit>()
                  .reorderItems(
                    templateId: templateId,
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                  ),
              itemBuilder: (context, index) {
                final item = sorted[index];
                return ReorderableDragStartListener(
                  key: ValueKey(item.id),
                  index: index,
                  child: ChecklistTemplateItemTile(item: item),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
