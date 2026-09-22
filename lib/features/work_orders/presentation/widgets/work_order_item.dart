import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_indication_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_rich_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class WorkOrderItem extends StatelessWidget {
  const WorkOrderItem({super.key, required this.workOrder});
  final WorkOrderEntity workOrder;

  @override
  Widget build(BuildContext context) {
    final isPendingApproval = workOrder.status.isPendingConclusionApproval;

    return Card(
      shape: isPendingApproval
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.p12),
              side: const BorderSide(color: AppColors.warning, width: 2),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p8),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            if (isPendingApproval) ...[
              Container(
                margin: const EdgeInsets.only(bottom: Sizes.p8),
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.p8,
                  vertical: Sizes.p4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Sizes.p8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PlatformIcon(
                      materialIcon: Icons.pending_actions,
                      cupertinoIcon: CupertinoIcons.clock_fill,
                      color: AppColors.warning,
                      size: 16,
                    ),
                    gapW8,
                    Flexible(
                      child: BaseText.caption(
                        'Aguardando aprovação de conclusão'.hardcoded,
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            BaseText.title(workOrder.title),
            gapH4,
            if (workOrder.description != null)
              BaseText(
                workOrder.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            gapH8,
            BaseRichText(
              texts: [
                const BaseText('Criado em: ', fontWeight: FontWeight.bold),
                BaseText(
                  workOrder.createdAt.formatDate(DateFormatType.ddMMyyyyHHmm),
                ),
              ],
            ),
            gapH8,
            Wrap(
              spacing: Sizes.p4,
              runSpacing: Sizes.p4,
              children: [
                BaseIndicationItem(
                  label: workOrder.type.label,
                  color: workOrder.type.color,
                ),

                BaseIndicationItem(
                  label: workOrder.priority.label,
                  color: workOrder.priority.color,
                ),

                BaseIndicationItem(
                  label: workOrder.status.label,
                  color: workOrder.status.color,
                ),
                if (workOrder.isDeleted) ...[
                  BaseIndicationItem(
                    label: 'Excluída'.hardcoded,
                    color: Colors.red,
                  ),
                ],
                if (workOrder.estimatedDuration != null) ...[
                  BaseIndicationItem(
                    label: '${workOrder.estimatedDuration} min',
                    color: workOrder.status.color,
                  ),
                ],
                if (workOrder.scheduledDate != null) ...[
                  BaseIndicationItem(
                    label: workOrder.scheduledDate!.formatDate(
                      DateFormatType.yMMMMd,
                    ),
                    color: workOrder.status.color,
                  ),
                ],
              ],
            ),
            BlocSelector<UsersCubit, UsersState, UserProfileEntity?>(
              selector: (state) => state.users.firstWhereOrNull(
                (e) => e.id == workOrder.assignedToId,
              ),
              builder: (context, user) {
                if (user == null) {
                  return const SizedBox.shrink();
                }
                return Align(
                  alignment: .centerLeft,
                  child: BaseText(user.name, fontWeight: FontWeight.bold),
                );
              },
            ),
            Align(
              alignment: .centerRight,
              child: BaseButton.text(
                text: 'Detalhes'.hardcoded,
                onPressed: () => context
                    .read<WorkOrdersCubit>()
                    .navigateToWorkOrderDetails(workOrder.id),
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.info,
                  cupertinoIcon: CupertinoIcons.info,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
