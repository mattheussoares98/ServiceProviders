import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/widgets/work_order_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/chip/base_removable_chip.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

part '../work_orders/widgets/oders_items/active_filters.dart';

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
        _ActiveFilters(),
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
                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: BaseText.error(
                              'Nenhuma ordem foi encontrada'.hardcoded,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ResponsiveListFlow(
                          scrollController: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
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
                          // if (!state.hasMorePages && workOrders.isNotEmpty) {
                          //   return Padding(
                          //     padding: const EdgeInsets.all(Sizes.p12),
                          //     child: BaseText.bodySmall(
                          //       'Todas as ordens foram carregadas'.hardcoded,
                          //       color: context.colorScheme.onSurface.withValues(
                          //         alpha: 0.5,
                          //       ),
                          //     ),
                          //   );
                          // }
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
