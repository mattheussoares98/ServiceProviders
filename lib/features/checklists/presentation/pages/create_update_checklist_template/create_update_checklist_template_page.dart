import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/pages/create_update_checklist_template/widgets/checklist_template_delete_action.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/pages/create_update_checklist_template/widgets/checklist_template_form.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/pages/create_update_checklist_template/widgets/checklist_template_items_section.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_running.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

@RoutePage()
class CreateUpdateChecklistTemplatePage extends HookWidget {
  const CreateUpdateChecklistTemplatePage({super.key, this.template});

  final ChecklistTemplateEntity? template;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChecklistTemplatesCubit>();

    observeRunning([
      ObservedLoadingTarget(
        cubit,
        sections: {
          ChecklistTemplatesSections.saveTemplate,
          ChecklistTemplatesSections.deleteTemplate,
          ChecklistTemplatesSections.deleteItem,
        },
      ),
    ]);

    useEffect(() {
      cubit.selectTemplate(template);
      return null;
    }, [template?.id]);

    final isEditing = template != null;

    return BaseScaffold(
      appBar: BaseAppBar(
        title: isEditing
            ? 'Editando checklist'.hardcoded
            : 'Criando checklist'.hardcoded,
        actions: [
          if (template != null)
            ChecklistTemplateDeleteAction(template: template!),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChecklistTemplateForm(template: template),
          if (isEditing) ...[
            gapH24,
            ChecklistTemplateItemsSection(templateId: template!.id),
          ],
        ],
      ),
    );
  }
}
