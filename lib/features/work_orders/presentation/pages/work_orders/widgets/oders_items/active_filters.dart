part of 'orders_items.dart';

/// Horizontal scrollable row that shows active filter chips below the app bar.
class _ActiveFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final filter = context.select<WorkOrdersCubit, WorkOrderFilter>(
      (c) => c.state.activeFilter,
    );
    if (filter.isEmpty) return const SizedBox.shrink();

    final chips = <Widget>[
      // "Clear all" chip
      ActionChip(
        avatar: const Icon(CupertinoIcons.clear, size: 14),
        label: Text('Limpar filtros'.hardcoded),
        onPressed: context.read<WorkOrdersCubit>().clearFilter,
        backgroundColor: context.colorScheme.errorContainer,
        labelStyle: TextStyle(color: context.colorScheme.onErrorContainer),
      ),
      for (final s in filter.statuses)
        BaseRemovableChip(
          label: s.label,
          onRemove: () {
            final newStatuses = filter.statuses.where((e) => e != s).toList();
            context.read<WorkOrdersCubit>().applyFilter(
              filter.copyWith(statuses: [...newStatuses]),
            );
          },
        ),
      for (final p in filter.priorities)
        BaseRemovableChip(
          label: p.label,
          onRemove: () {
            final newPriorities = filter.priorities
                .where((e) => e != p)
                .toList();
            context.read<WorkOrdersCubit>().applyFilter(
              filter.copyWith(priorities: [...newPriorities]),
            );
          },
        ),
      if (filter.type != null)
        BaseRemovableChip(
          label: filter.type!.label,
          onRemove: () => context.read<WorkOrdersCubit>().applyFilter(
            filter.copyWith(annulType: true),
          ),
        ),
      if (filter.assignedToId != null)
        BaseRemovableChip(
          label: 'Responsável',
          onRemove: () => context.read<WorkOrdersCubit>().applyFilter(
            filter.copyWith(annulAssignedToId: true),
          ),
        ),
      if (filter.scheduledDateFrom != null || filter.scheduledDateTo != null)
        BaseRemovableChip(
          label: 'Data programada',
          onRemove: () => context.read<WorkOrdersCubit>().applyFilter(
            filter.copyWith(
              annulScheduledDateFrom: true,
              annulScheduledDateTo: true,
            ),
          ),
        ),
      if (filter.searchText != null && filter.searchText!.isNotEmpty)
        BaseRemovableChip(
          label: '"${filter.searchText}"',
          onRemove: () => context.read<WorkOrdersCubit>().applyFilter(
            filter.copyWith(annulSearchText: true),
          ),
        ),
    ];

    if (PlatformUtil.isMobile) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Sizes.p8),
        child: SizedBox(
          height: Sizes.p48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Sizes.p12),
            itemCount: chips.length,
            separatorBuilder: (_, _) => const SizedBox(width: Sizes.p8),
            itemBuilder: (_, i) => chips[i],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(Sizes.p12),
      child: Wrap(spacing: Sizes.p8, runSpacing: Sizes.p8, children: chips),
    );
  }
}
