import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachments.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_sub_action.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/edit_and_delete_icons.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/info_items.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/observations_section.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/request_completion_dialog.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/request_pause_dialog.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/work_order_approval_banner.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';
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
      create: (context) => GetIt.I<AttachmentsCubit>()..init(workOrderId),
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

    useEffect(() {
      pauseCubit.loadPauseRequests(workOrder.id);
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
                InfoItems(workOrder: workOrder),
                Attachments(
                  workOrderId: workOrder.id,
                  isEditing: false,
                  padding: EdgeInsets.zero,
                ),
                ObservationsSection(
                  workOrderId: workOrder.id,
                  companyId: workOrder.companyId,
                ),
                gapSliverH24,
              ],
            ),
            bottomNavigationBar: _buildBottomActions(
              context,
              workOrder,
              currentUserId,
              pauseCubit,
            ),
          );
        },
      ),
    );
  }

  Widget? _buildBottomActions(
    //TODO create a widget instead
    BuildContext context,
    WorkOrderEntity workOrder,
    String currentUserId,
    PauseWorkflowCubit pauseCubit,
  ) {
    if (workOrder.status == WorkOrderStatus.inProgress) {
      return Container(
        padding: const EdgeInsets.all(Sizes.p16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Pausar'.hardcoded,
                onTap: () async {
                  final result = await showModalPage<bool>(
                    RequestPauseDialog(
                      companyId: workOrder.companyId,
                      workOrderId: workOrder.id,
                      currentUserId: currentUserId,
                    ),
                    context,
                    useDraggable: false,
                  );

                  if (result == true && context.mounted) {
                    unawaited(
                      context
                          .read<WorkOrdersCubit>()
                          .loadWorkOrdersAndChangeRequests(),
                    );
                  }
                },
              ),
            ),
            gapW12,
            Expanded(
              child: PrimaryButton(
                text: 'Solicitar conclusão'.hardcoded,
                onTap: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => RequestCompletionDialog(
                      companyId: workOrder.companyId,
                      workOrderId: workOrder.id,
                      currentUserId: currentUserId,
                    ),
                  );
                  if (result == true && context.mounted) {
                    unawaited(
                      context
                          .read<WorkOrdersCubit>()
                          .loadWorkOrdersAndChangeRequests(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
    }

    if (workOrder.status == WorkOrderStatus.onHold) {
      return Container(
        padding: const EdgeInsets.all(Sizes.p16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: PrimaryButton(
          text: 'Retomar trabalho'.hardcoded,
          onTap: () async {
            final updatedWo = workOrder.copyWith(
              status: WorkOrderStatus.inProgress,
            );
            final success = await context.read<WorkOrdersCubit>().saveWorkOrder(
              //TODO create a new method to change the status
              id: updatedWo.id,
              locationId: updatedWo.locationId,
              createdById: updatedWo.createdById,
              title: updatedWo.title,
              priority: updatedWo.priority,
              status: updatedWo.status,
              type: updatedWo.type,
            );
            if (success) {
              unawaited(pauseCubit.loadPauseRequests(workOrder.id));
            }
          },
        ),
      );
    }

    return null;
  }
}
