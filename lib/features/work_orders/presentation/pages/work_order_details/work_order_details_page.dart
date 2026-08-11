import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachments.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_sub_action.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/edit_and_delete_icons.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/info_items.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/observations_section.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/work_order_approval_banner.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/work_order_bottom_actions.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/work_order_execution_timer_card.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

@RoutePage()
class WorkOrderDetailsPage extends StatelessWidget {
  const WorkOrderDetailsPage({super.key, required this.workOrderId});

  final String workOrderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<AttachmentsCubit>(param1: workOrderId),
      child: BlocSelector<WorkOrdersCubit, WorkOrdersState, WorkOrderEntity?>(
        selector: (state) =>
            state.workOrders.firstWhereOrNull((e) => e.id == workOrderId),
        builder: (context, workOrder) {
          if (workOrder == null) {
            return BaseScaffold(
              appBar: BaseAppBar(
                title: 'Detalhes da ordem de serviço'.hardcoded,
              ),
              body: Center(
                child: BaseText.error(
                  'Ordem de serviço não encontrada'.hardcoded,
                ),
              ),
            );
          }
          return _WorkOrderDetails(workOrder: workOrder);
        },
      ),
    );
  }
}

class _WorkOrderDetails extends HookWidget {
  const _WorkOrderDetails({required this.workOrder});
  final WorkOrderEntity workOrder;

  @override
  Widget build(BuildContext context) {
    final pauseCubit = useMemoized(() => GetIt.I<PauseWorkflowCubit>());
    final sessionCubit = context.read<SessionCubit>();
    final serviceProvidersCubit = context.read<ServiceProvidersCubit>();

    useEffect(() {
      pauseCubit.loadPauseRequests(workOrder.id);
      if (workOrder.serviceProviderCompanyId != null) {
        serviceProvidersCubit.ensureProfilesLoaded(
          workOrder.serviceProviderCompanyId!,
        );
      }
      return null;
    }, [workOrder.id]);

    observeLoading(
      [context.read<WorkOrdersCubit>()],
      statuses: {StateStatus.deleting},
    );

    final canApprovePause = context.hasPermission(
      const ActionPermission.workOrderSubAction(
        WorkOrderSubAction.approvePause,
      ),
    );
    final canApproveCompletion = context.hasPermission(
      const ActionPermission.workOrderSubAction(
        WorkOrderSubAction.approveCompletion,
      ),
    );

    final currentUserId = sessionCubit.state.user.id;

    return MultiBlocProvider(
      providers: [BlocProvider.value(value: pauseCubit)],
      child: BlocBuilder<PauseWorkflowCubit, PauseWorkflowState>(
        builder: (context, pauseState) {
          return BaseScaffold(
            isScrollable: false,
            appBar: BaseAppBar(
              title: 'Detalhes da ordem de serviço'.hardcoded,
              actions: [EditAndDeleteIcons(workOrderId: workOrder.id)],
            ),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: WorkOrderApprovalBanner(
                    workOrder: workOrder,
                    pauseRequests: pauseState.pauseRequests,
                    currentUserId: currentUserId,
                    canApprovePause: canApprovePause,
                    canApproveCompletion: canApproveCompletion,
                    onRefresh: () {
                      context
                          .read<WorkOrdersCubit>()
                          .loadWorkOrdersAndChangeRequests();
                      pauseCubit.loadPauseRequests(workOrder.id);
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: WorkOrderExecutionTimerCard(workOrder: workOrder),
                ),
                InfoItems(workOrder: workOrder),
                const Attachments(isEditing: false, padding: EdgeInsets.zero),
                ObservationsSection(
                  workOrderId: workOrder.id,
                  companyId: workOrder.companyId,
                ),
                gapSliverH24,
              ],
            ),
            bottomNavigationBar: WorkOrderBottomActions(
              workOrder: workOrder,
              currentUserId: currentUserId,
              pauseCubit: pauseCubit,
            ),
          );
        },
      ),
    );
  }
}
