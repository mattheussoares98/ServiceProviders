import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class DeletedWorkOrderBanner extends StatelessWidget {
  const DeletedWorkOrderBanner({required this.workOrder, super.key});

  final WorkOrderEntity workOrder;

  @override
  Widget build(BuildContext context) {
    final bannerColor = AppColors.error.withValues(alpha: 0.1);
    final borderColor = AppColors.error.withValues(alpha: 0.7);

    final deletedDateStr = workOrder.deletedAt?.formatDate(.ddMMyyyyHHmm);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        Sizes.p16,
        Sizes.p16,
        Sizes.p16,
        Sizes.p8,
      ),
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PlatformIcon(
                materialIcon: Icons.delete_forever_rounded,
                cupertinoIcon: CupertinoIcons.delete_solid,
                color: AppColors.error,
              ),
              gapW8,
              Expanded(
                child: BaseText.title('Ordem de serviço excluída'.hardcoded),
              ),
            ],
          ),
          gapH8,
          BaseText(
            deletedDateStr != null
                ? 'Esta ordem de serviço foi excluída em $deletedDateStr. Suas ações estão bloqueadas.'
                      .hardcoded
                : 'Esta ordem de serviço foi excluída. Suas ações estão bloqueadas.'
                      .hardcoded,
          ),
          gapH12,
          Align(
            alignment: Alignment.centerRight,
            child: BaseButton(
              permission: const ActionPermission.resource(
                resourceType: ResourceType.workOrders,
                permissionAction: PermissionAction.delete,
              ),
              color: AppColors.error,
              text: 'Restaurar ordem de serviço'.hardcoded,
              onTap: () async {
                final confirmed = await showAlertDialog(
                  context: context,
                  title: 'Restaurar ordem de serviço'.hardcoded,
                  contentText:
                      'Deseja realmente restaurar esta ordem de serviço? Ela voltará para a lista de ordens ativas.'
                          .hardcoded,
                  defaultActionText: 'Sim'.hardcoded,
                  cancelActionText: 'Cancelar'.hardcoded,
                );
                if (confirmed == true && context.mounted) {
                  await context.read<WorkOrdersCubit>().restoreWorkOrder(
                    workOrder.id,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
