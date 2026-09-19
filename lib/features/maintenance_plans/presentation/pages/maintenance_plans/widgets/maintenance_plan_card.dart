import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/extensions/interval_unit_ui_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_switch.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class MaintenancePlanCard extends StatelessWidget {
  const MaintenancePlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    required this.onToggleActive,
    required this.onDelete,
  });
  //TODO review this Card
  final MaintenancePlanEntity plan;
  final VoidCallback onTap;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final nextDateText = plan.nextDueDate != null
        ? plan.nextDueDate!.formatDate()
        : 'Não definida'.hardcoded;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Sizes.p8,
        vertical: Sizes.p4,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Sizes.p8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BaseText.titleMedium(
                          plan.title,
                          fontWeight: FontWeight.bold,
                        ),
                        if (plan.description != null &&
                            plan.description!.isNotEmpty) ...[
                          gapH4,
                          BaseText.bodySmall(
                            plan.description!,
                            color: context.colorScheme.onSurfaceVariant,
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
                  ),
                  gapW8,
                  BaseSwitch(
                    value: plan.isActive,
                    onChanged: (_) => onToggleActive(),
                  ),
                ],
              ),
              gapH12,
              Wrap(
                spacing: Sizes.p8,
                runSpacing: Sizes.p8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.p8,
                      vertical: Sizes.p4,
                    ),
                    decoration: BoxDecoration(
                      color: plan.priority.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(Sizes.p4),
                    ),
                    child: BaseText.caption(
                      plan.priority.label,
                      color: plan.priority.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.p8,
                      vertical: Sizes.p4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(Sizes.p4),
                    ),
                    child: BaseText.caption(
                      plan.intervalUnit.formatInterval(plan.intervalValue),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.p8,
                      vertical: Sizes.p4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(Sizes.p4),
                    ),
                    child: BaseText.caption(
                      'Antecedência: ${plan.leadTimeDays}d'.hardcoded,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              gapH12,
              Row(
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
                  BaseIconButton(
                    permission: const ActionPermission.resource(
                      resourceType: ResourceType.maintenancePlans,
                      permissionAction: PermissionAction.delete,
                    ),
                    onPressed: onDelete,
                    platformIcon: const PlatformIcon(
                      materialIcon: Icons.delete_outline,
                      cupertinoIcon: CupertinoIcons.trash,
                      color: AppColors.error,
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
