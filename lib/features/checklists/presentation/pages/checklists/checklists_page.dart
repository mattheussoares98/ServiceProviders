import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/pages/checklists/widgets/checklist_templates_list.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

@RoutePage()
class ChecklistsPage extends StatelessWidget {
  const ChecklistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      onRefresh: () => context.read<ChecklistTemplatesCubit>().loadTemplates(),
      isScrollable: false,
      appBar: BaseAppBar(
        title: 'Checklists'.hardcoded,
        actions: [
          BaseIconButton(
            permission: const ActionPermission.resource(
              resourceType: ResourceType.checklists,
              permissionAction: PermissionAction.create,
            ),
            onPressed: () => context
                .read<ChecklistTemplatesCubit>()
                .navigateToCreateUpdateTemplate(),
            platformIcon: const PlatformIcon(
              materialIcon: Icons.add,
              cupertinoIcon: CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body:
          BaseStateView<
            ChecklistTemplatesCubit,
            ChecklistTemplatesState,
            List<ChecklistTemplateEntity>
          >(
            dataSelector: (state) => state.templates,
            onRetry: () =>
                context.read<ChecklistTemplatesCubit>().loadTemplates(),
            builder: (context, templates) =>
                ChecklistTemplatesList(templates: templates),
          ),
    );
  }
}
