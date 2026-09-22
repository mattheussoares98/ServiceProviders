part of '../../../widgets/orders_items.dart';

class _PendingConclusionBanner extends StatelessWidget {
  const _PendingConclusionBanner();

  @override
  Widget build(BuildContext context) {
    // Check permission to manage pending requests
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

    // Check if the current filter is already showing only pending conclusion approval
    final isAlreadyFiltered = context.select<WorkOrdersCubit, bool>(
      (c) =>
          c.state.activeFilter.statuses.length == 1 &&
          c.state.activeFilter.statuses.first ==
              WorkOrderStatus.pendingConclusionApproval,
    );

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Sizes.p12,
        vertical: Sizes.p4,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.p12,
        vertical: Sizes.p8,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Sizes.p8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const PlatformIcon(
            materialIcon: Icons.warning_amber_rounded,
            cupertinoIcon: CupertinoIcons.exclamationmark_triangle_fill,
            color: AppColors.warning,
            size: 20,
          ),
          gapW8,
          Expanded(
            child: BaseText.bodySmall(
              '$pendingCount ordens aguardando aprovação de conclusão'
                  .hardcoded,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
          if (!isAlreadyFiltered) ...[
            gapW8,
            BaseButton.text(
              text: 'Ver todas'.hardcoded,
              onPressed: () =>
                  context.read<WorkOrdersCubit>().filterByPendingConclusion(),
              textColor: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }
}
