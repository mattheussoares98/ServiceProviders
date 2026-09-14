import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/badges/quantity_badge.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

//TODO review this widget
class PendingConclusionAppBarButton extends StatelessWidget {
  const PendingConclusionAppBarButton({super.key});

  @override
  Widget build(BuildContext context) {
    final canManagePendingRequests = context.hasPermission(
      const ActionPermission.workOrderSubAction(
        WorkOrderSubAction.managePendingRequests,
      ),
    );
    if (!canManagePendingRequests) return const SizedBox.shrink();

    final pendingCount = context.select<WorkOrdersCubit, int>(
      (c) => c.state.pendingConclusionCount,
    );
    if (pendingCount <= 0) return const SizedBox.shrink();

    final isFiltered = context.select<WorkOrdersCubit, bool>(
      (c) =>
          c.state.activeFilter.statuses.length == 1 &&
          c.state.activeFilter.statuses.first ==
              WorkOrderStatus.pendingConclusionApproval,
    );
    return CupertinoButton(
      onPressed: () {
        if (isFiltered) {
          context.read<WorkOrdersCubit>().clearFilter();
        } else {
          context.read<WorkOrdersCubit>().filterByPendingConclusion();
        }
      },
      padding: EdgeInsets.zero,
      child: QuantityBadge(
        quantity: pendingCount,
        isSelected: isFiltered,
        platformIcon: const PlatformIcon(
          materialIcon: Icons.pending_actions,
          cupertinoIcon: CupertinoIcons.clock_fill,
          color: AppColors.warning,
        ),
      ),
    );
  }
}
