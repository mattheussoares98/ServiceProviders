import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/extensions/checklist_item_type_ui_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

/// A single configured item of a checklist template, with edit and delete.
class ChecklistTemplateItemTile extends StatelessWidget {
  const ChecklistTemplateItemTile({super.key, required this.item});

  final ChecklistItemEntity item;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChecklistTemplatesCubit>();
    void edit() => cubit.navigateToCreateUpdateItem(
      templateId: item.templateId,
      item: item,
    );

    final subtitle = item.isRequired
        ? '${item.type.label} · ${'obrigatório'.hardcoded}'
        : item.type.label;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: edit,
        child: BaseListTile(
          platformIcon: const PlatformIcon(
            materialIcon: Icons.checklist_outlined,
            cupertinoIcon: CupertinoIcons.list_bullet,
          ),
          title: item.label,
          subtitle: subtitle,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BaseIconButton(
                permission: const ActionPermission.resource(
                  resourceType: ResourceType.checklists,
                  permissionAction: PermissionAction.update,
                ),
                onPressed: edit,
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.edit_outlined,
                  cupertinoIcon: CupertinoIcons.pencil,
                ),
              ),
              BaseIconButton(
                permission: const ActionPermission.resource(
                  resourceType: ResourceType.checklists,
                  permissionAction: PermissionAction.delete,
                ),
                onPressed: () => showAlertDialog(
                  context: context,
                  title: 'Atenção!'.hardcoded,
                  contentText:
                      'Deseja realmente excluir o item "${item.label}"?'
                          .hardcoded,
                  defaultActionText: 'Sim'.hardcoded,
                  cancelActionText: 'Não'.hardcoded,
                  onOkPressed: () => cubit.deleteItem(
                    id: item.id,
                    templateId: item.templateId,
                  ),
                ),
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.delete_outline,
                  cupertinoIcon: CupertinoIcons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
