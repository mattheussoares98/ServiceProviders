import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/evaluate_prerequisites_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/widgets/work_order_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/chip/base_removable_chip.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/prerequisites/prerequisite_guide_card.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

part '../work_orders/widgets/oders_items/active_filters.dart';
part '../work_orders/widgets/oders_items/pending_conclusion_banner.dart';

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
        const _PendingConclusionBanner(),
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
                    final hasFilter = context.select<WorkOrdersCubit, bool>(
                      (c) => c.state.activeFilter != const WorkOrderFilter(),
                    );
                    if (hasFilter) {
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

                    WorkType workType = WorkType.hybrid;
                    int locationsCount = 0;
                    int areasCount = 0;
                    int customersCount = 0;
                    int assetsCount = 0;
                    bool hasLocationCreate = true;
                    bool hasAssetCreate = true;

                    try {
                      final company =
                          context.watch<CompanyCubit>().state.company;
                      if (company != null) workType = company.workType;
                    } catch (_) {}

                    try {
                      final locState = context.watch<LocationsCubit>().state;
                      locationsCount = locState.locations.length;
                      areasCount = locState.allAreas.length;
                    } catch (_) {}

                    try {
                      final custState = context.watch<CustomersCubit>().state;
                      customersCount = custState.customers.length;
                    } catch (_) {}

                    try {
                      final assetState = context.watch<AssetsCubit>().state;
                      assetsCount = assetState.assets.length;
                    } catch (_) {}

                    try {
                      final userCubit = context.watch<UsersCubit>();
                      hasLocationCreate = userCubit.hasPermission(
                        const ActionPermission.resource(
                          resourceType: ResourceType.locations,
                          permissionAction: PermissionAction.create,
                        ),
                      );
                      hasAssetCreate = userCubit.hasPermission(
                        const ActionPermission.resource(
                          resourceType: ResourceType.assets,
                          permissionAction: PermissionAction.create,
                        ),
                      );
                    } catch (_) {}

                    final eval = const EvaluatePrerequisitesUseCase()(
                      EvaluatePrerequisitesParams(
                        workType: workType,
                        locationsCount: locationsCount,
                        areasCount: areasCount,
                        customersCount: customersCount,
                        assetsCount: assetsCount,
                        hasLocationCreatePermission: hasLocationCreate,
                        hasAssetCreatePermission: hasAssetCreate,
                      ),
                    );

                    if (eval.hasPendingRequiredPrerequisites) {
                      return PrerequisiteGuideCard(steps: eval.steps);
                    }

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
                  return BlocBuilder<WorkOrdersCubit, WorkOrdersState>(
                    buildWhen: (prev, curr) =>
                        prev.isLoadingMore != curr.isLoadingMore,
                    builder: (context, state) {
                      final allLoadedWorkOrdersWidget =
                          !state.hasMorePages && workOrders.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(Sizes.p12),
                              child: BaseText.bodySmall(
                                'Todas as ordens foram carregadas'.hardcoded,
                                textAlign: .center,
                                color: context.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            )
                          : const SizedBox.shrink();

                      return Column(
                        children: [
                          Expanded(
                            child: ResponsiveListFlow(
                              padding: .zero,
                              scrollController: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: workOrders.length + 1,
                              itemBuilder: (context, index) {
                                if (index == workOrders.length) {
                                  return allLoadedWorkOrdersWidget;
                                }

                                final workOrder = workOrders[index];
                                return WorkOrderItem(workOrder: workOrder);
                              },
                            ),
                          ),
                          if (state.isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.all(Sizes.p16),
                              child: LoadingCircle(),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
        ),
      ],
    );
  }
}
