import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

/// Renders the company's checklist templates, alphabetically sorted.
class ChecklistTemplatesList extends StatelessWidget {
  const ChecklistTemplatesList({super.key, required this.templates});

  final List<ChecklistTemplateEntity> templates;

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return Center(
        child: BaseText.bodyMedium('Nenhum checklist cadastrado'.hardcoded),
      );
    }

    final sorted = [...templates]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return ResponsiveListFlow(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final template = sorted[index];
        void openTemplate() => context
            .read<ChecklistTemplatesCubit>()
            .navigateToCreateUpdateTemplate(template: template);

        return Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: openTemplate,
            child: BaseListTile(
              platformIcon: const PlatformIcon(
                materialIcon: Icons.fact_check_outlined,
                cupertinoIcon: CupertinoIcons.checkmark_square,
              ),
              title: template.name,
              subtitle: template.description,
              trailing: BaseIconButton(
                permission: const ActionPermission.resource(
                  resourceType: ResourceType.checklists,
                  permissionAction: PermissionAction.update,
                ),
                onPressed: openTemplate,
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.edit_outlined,
                  cupertinoIcon: CupertinoIcons.pencil,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
