import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/cubits/maintenance_plans/maintenance_plans_cubit.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/extensions/interval_unit_ui_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_indication_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class MaintenancePlanCard extends StatelessWidget {
  const MaintenancePlanCard({super.key, required this.plan});
  final MaintenancePlanEntity plan;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MaintenancePlansCubit>();
    final nextDateText = plan.nextDueDate != null
        ? plan.nextDueDate!.formatDate()
        : 'Não definida'.hardcoded;

    final bool canUpdateMaintenancePlan = context.hasPermission(
      const ActionPermission.resource(
        resourceType: ResourceType.maintenancePlans,
        permissionAction: PermissionAction.update,
      ),
    );

    void onTap() =>
        cubit.navigateToCreateUpdateMaintenancePlan(maintenancePlan: plan);

    Future<void> onGenerateWorkOrder() async {
      final confirmed = await showAlertDialog(
        context: context,
        title: 'Gerar ordem de serviço'.hardcoded,
        contentText:
            'Deseja gerar a ordem de serviço para este plano agora?'.hardcoded,
        defaultActionText: 'Gerar'.hardcoded,
        cancelActionText: 'Cancelar'.hardcoded,
      );
      if (confirmed == true) {
        await cubit.generateWorkOrder(plan.id);
      }
    }

    return Card(
      clipBehavior: .hardEdge,
      child: InkWell(
        onTap: canUpdateMaintenancePlan ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  BaseText.title(plan.title, textAlign: .start),
                  if (plan.description?.isNotEmpty ?? false) ...[
                    gapH4,
                    BaseText.bodySmall(
                      plan.description!,
                      color: context.colorScheme.onSurfaceVariant,
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
              gapH12,
              Wrap(
                spacing: Sizes.p8,
                runSpacing: Sizes.p8,
                children: [
                  BaseIndicationItem(
                    label: plan.priority.label,
                    color: plan.priority.color,
                  ),
                  BaseIndicationItem(
                    label: plan.intervalUnit.formatInterval(plan.intervalValue),
                    color: Colors.black,
                  ),
                  BaseIndicationItem(
                    label: 'Antecedência: ${plan.leadTimeDays}d'.hardcoded,
                    color: Colors.black,
                  ),
                ],
              ),
              gapH12,
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        const PlatformIcon(
                          materialIcon: Icons.calendar_today_outlined,
                          cupertinoIcon: CupertinoIcons.calendar,
                          size: Sizes.p16,
                        ),
                        gapW8,
                        Expanded(
                          child: BaseText.caption(
                            'Próxima: $nextDateText'.hardcoded,
                            color: context.colorScheme.onSurfaceVariant,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BaseIconButton(
                    permission: const ActionPermission.resource(
                      resourceType: ResourceType.maintenancePlans,
                      permissionAction: PermissionAction.update,
                    ),
                    onPressed: onGenerateWorkOrder,
                    platformIcon: const PlatformIcon(
                      materialIcon: Icons.play_arrow_outlined,
                      cupertinoIcon: CupertinoIcons.play,
                    ),
                  ),
                  BaseIconButton(
                    permission: const ActionPermission.resource(
                      resourceType: ResourceType.maintenancePlans,
                      permissionAction: PermissionAction.update,
                    ),
                    onPressed: onTap,
                    platformIcon: const PlatformIcon(
                      materialIcon: Icons.edit_outlined,
                      cupertinoIcon: CupertinoIcons.pencil,
                    ),
                  ),
                ],
              ),
              if (plan.lastError != null && plan.lastError!.isNotEmpty) ...[
                gapH8,
                Container(
                  padding: const EdgeInsets.all(Sizes.p8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Sizes.p4),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const PlatformIcon(
                        materialIcon: Icons.warning_amber_rounded,
                        cupertinoIcon: CupertinoIcons.exclamationmark_triangle,
                        color: AppColors.error,
                        size: Sizes.p16,
                      ),
                      gapW8,
                      Expanded(
                        child: BaseText.caption(
                          'Falha na última geração: ${plan.lastError}'
                              .hardcoded,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
