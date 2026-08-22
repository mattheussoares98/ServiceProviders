import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_rich_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class WorkOrderApprovalBanner extends HookWidget {
  const WorkOrderApprovalBanner({
    required this.workOrder,
    required this.pauseRequests,
    required this.currentUserId,
    required this.onRefresh,
    super.key,
  });

  final WorkOrderEntity workOrder;
  final List<PauseRequestEntity> pauseRequests;
  final String currentUserId;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (!context.hasPermission(
      const ActionPermission.workOrderSubAction(.managePendingRequests),
    )) {
      return Center(
        child: BaseText.error(
          'Seu usuário não possui permissão para manusear solicitações pendentes'
              .hardcoded,
        ),
      );
    }

    final pendingCount = pauseRequests
        .where((r) => r.status == PauseRequestStatus.pending)
        .length;

    final isPendingStatus = workOrder.status.isPendingApproval;

    if (!isPendingStatus && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    final isPauseApproval = workOrder.status.isPaused;

    final color = workOrder.status.color;
    final bannerColor = color.withValues(alpha: 0.1);
    final borderColor = color.withValues(alpha: 0.7);
    final iconColor = color.withValues(alpha: 0.9);

    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.p8),
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseRichText(
            texts: [
              Padding(
                padding: const EdgeInsets.only(right: Sizes.p8),
                child: PlatformIcon(
                  materialIcon: isPauseApproval
                      ? Icons.pause_circle_filled
                      : Icons.task_alt,
                  cupertinoIcon: isPauseApproval
                      ? CupertinoIcons.pause_circle_fill
                      : CupertinoIcons.check_mark_circled,
                  color: iconColor,
                ),
              ),
              BaseText.title(
                '$pendingCount ${pendingCount > 1 ? 'solicitações pendentes' : 'solicitação pendente'}'
                    .hardcoded,
                // fontWeight: FontWeight.bold,
                // color: iconColor,
              ),
            ],
          ),
          gapH12,
          Align(
            alignment: Alignment.centerRight,
            child: BaseButton(
              color: iconColor,
              text: 'Ver solicitações'.hardcoded,
              onTap: () async {
                await context
                    .read<WorkOrdersCubit>()
                    .navigateToWorkOrderPendingRequests(
                      workOrder,
                      currentUserId,
                    );
                onRefresh();
              },
            ),
          ),
        ],
      ),
    );
  }
}
