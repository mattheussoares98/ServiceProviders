import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

/// App bar action that deletes a checklist template after confirmation.
class ChecklistTemplateDeleteAction extends StatelessWidget {
  const ChecklistTemplateDeleteAction({super.key, required this.template});

  final ChecklistTemplateEntity template;

  @override
  Widget build(BuildContext context) {
    return BaseIconButton(
      permission: const ActionPermission.resource(
        resourceType: ResourceType.checklists,
        permissionAction: PermissionAction.delete,
      ),
      onPressed: () {
        showAlertDialog(
          context: context,
          title: 'Atenção!'.hardcoded,
          contentText:
              'Deseja realmente excluir o checklist "${template.name}"?'
                  .hardcoded,
          defaultActionText: 'Sim'.hardcoded,
          cancelActionText: 'Não'.hardcoded,
          onOkPressed: () async {
            final succeeds = await context
                .read<ChecklistTemplatesCubit>()
                .deleteTemplate(template.id);

            if (succeeds && context.mounted) Navigator.of(context).pop();
          },
        );
      },
      platformIcon: const PlatformIcon(
        materialIcon: Icons.delete,
        cupertinoIcon: CupertinoIcons.delete,
        color: Colors.red,
      ),
    );
  }
}
