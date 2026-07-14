import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/widgets/work_order_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class OrdersItems extends StatefulWidget {
  const OrdersItems({super.key});

  @override
  State<OrdersItems> createState() => _OrdersItemsState();
}

class _OrdersItemsState extends State<OrdersItems> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      context.read<WorkOrdersCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActiveFiltersRow(),
        Expanded(
          child:
              BaseStateView<
                WorkOrdersCubit,
                WorkOrdersState,
                List<WorkOrderEntity>
              >(
                dataSelector: (state) => state.workOrders,
                onRetry: context
                    .read<WorkOrdersCubit>()
                    .loadWorkOrdersAndChangeRequests,
                builder: (context, workOrders) {
                  if (workOrders.isEmpty) {
                    return Center(
                      child: BaseText.error(
                        'Nenhuma ordem foi encontrada'.hardcoded,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ResponsiveListFlow(
                          scrollController: _scrollController,
                          itemCount: workOrders.length,
                          itemBuilder: (context, index) {
                            final workOrder = workOrders[index];
                            return WorkOrderItem(workOrder: workOrder);
                          },
                        ),
                      ),
                      // Pagination footer
                      BlocBuilder<WorkOrdersCubit, WorkOrdersState>(
                        buildWhen: (prev, curr) =>
                            prev.isLoadingMore != curr.isLoadingMore,
                        builder: (context, state) {
                          if (state.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.all(Sizes.p16),
                              child: LoadingCircle(),
                            );
                          }
                          if (!state.hasMorePages && workOrders.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(Sizes.p12),
                              child: BaseText.bodySmall(
                                'Todas as ordens foram carregadas'.hardcoded,
                                color: context.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  );
                },
              ),
        ),
      ],
    );
  }
}

/// Horizontal scrollable row that shows active filter chips below the app bar.
class _ActiveFiltersRow extends StatelessWidget {
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
        _FilterBadge(
          label: s.label,
          onRemove: () {
            final newStatuses = filter.statuses.where((e) => e != s).toList();
            context.read<WorkOrdersCubit>().applyFilter(
              filter.copyWith(statuses: newStatuses),
            );
          },
        ),
      for (final p in filter.priorities)
        _FilterBadge(
          label: p.label,
          onRemove: () {
            final newPriorities = filter.priorities
                .where((e) => e != p)
                .toList();
            context.read<WorkOrdersCubit>().applyFilter(
              filter.copyWith(priorities: newPriorities),
            );
          },
        ),
      if (filter.type != null)
        _FilterBadge(
          label: filter.type!.label,
          onRemove: () => context.read<WorkOrdersCubit>().applyFilter(
            filter.copyWith(annulType: true),
          ),
        ),
      if (filter.assignedToId != null)
        _FilterBadge(
          label: 'Responsável',
          onRemove: () => context.read<WorkOrdersCubit>().applyFilter(
            filter.copyWith(annulAssignedToId: true),
          ),
        ),
      if (filter.scheduledDateFrom != null || filter.scheduledDateTo != null)
        _FilterBadge(
          label: 'Data programada',
          onRemove: () => context.read<WorkOrdersCubit>().applyFilter(
            filter.copyWith(
              annulScheduledDateFrom: true,
              annulScheduledDateTo: true,
            ),
          ),
        ),
      if (filter.searchText != null && filter.searchText!.isNotEmpty)
        _FilterBadge(
          label: '"${filter.searchText}"',
          onRemove: () => context.read<WorkOrdersCubit>().applyFilter(
            filter.copyWith(annulSearchText: true),
          ),
        ),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Sizes.p12),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: Sizes.p8),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }
}

class _FilterBadge extends StatelessWidget {
  const _FilterBadge({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: onRemove,
    );
  }
}
