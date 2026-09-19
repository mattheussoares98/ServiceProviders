import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/cubits/maintenance_plans/maintenance_plans_cubit.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/pages/create_update_maintenance_plan/widgets/plan_form.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_running.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

@RoutePage()
class CreateUpdateMaintenancePlanPage extends HookWidget {
  const CreateUpdateMaintenancePlanPage({super.key, this.maintenancePlan});
  final MaintenancePlanEntity? maintenancePlan;

  @override
  Widget build(BuildContext context) {
    observeRunning([
      ObservedLoadingTarget(
        context.read<MaintenancePlansCubit>(),
        sections: const {
          MaintenancePlansSections.save,
          MaintenancePlansSections.delete,
        },
      ),
    ]);
    final cubit = context.read<MaintenancePlansCubit>();
    final isEditing = maintenancePlan != null;

    return BaseScaffold(
      observeScreenChanges: true,
      appBar: BaseAppBar(
        title: isEditing
            ? 'Editando plano de manutenção'.hardcoded
            : 'Criando plano de manutenção'.hardcoded,
        actions: [
          if (isEditing)
            BaseIconButton(
              permission: const ActionPermission.resource(
                resourceType: ResourceType.maintenancePlans,
                permissionAction: PermissionAction.delete,
              ),
              onPressed: () async {
                final proceed = await showAlertDialog(
                  context: context,
                  title: 'Excluir plano'.hardcoded,
                  contentText: 'Deseja excluir este plano?'.hardcoded,
                  defaultActionText: 'Sim'.hardcoded,
                  cancelActionText: 'Não'.hardcoded,
                );
                if (proceed == true &&
                    await cubit.deleteMaintenancePlan(maintenancePlan!.id) &&
                    context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              platformIcon: const PlatformIcon(
                materialIcon: Icons.delete_outline,
                cupertinoIcon: CupertinoIcons.trash,
                color: AppColors.error,
              ),
            ),
        ],
      ),
      body: PlanForm(maintenancePlan: maintenancePlan),
    );
  }
}
