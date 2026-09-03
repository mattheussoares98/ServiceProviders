import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachments.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_details/work_order_details_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/edit_and_delete_icons.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/info_items.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/deleted_work_order_banner.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/observations_section.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/work_order_bottom_actions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_running.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

@RoutePage()
class WorkOrderDetailsPage extends HookWidget {
  const WorkOrderDetailsPage({super.key, required this.workOrderId});

  final String workOrderId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              GetIt.I<WorkOrderDetailsCubit>()
                ..loadWorkOrder(workOrderId, showLoading: true),
        ),
        BlocProvider(
          create: (context) => GetIt.I<AttachmentsCubit>(param1: workOrderId),
        ),
        BlocProvider(
          create: (context) =>
              GetIt.I<WorkOrderObservationsCubit>()
                ..fetchObservations(workOrderId),
        ),
      ],
      child:
          BaseStateView<
            WorkOrderDetailsCubit,
            WorkOrderDetailsState,
            WorkOrderEntity?
          >(
            dataSelector: (state) => state.workOrder,
            onRetry: () => context.read<WorkOrderDetailsCubit>().loadWorkOrder(
              workOrderId,
              showLoading: true,
            ),
            builder: (context, workOrder) {
              if (workOrder == null) {
                return BaseScaffold(
                  appBar: BaseAppBar(
                    title: 'Detalhes da ordem de serviço'.hardcoded,
                  ),
                  body: Center(
                    child: BaseText.error(
                      'Ordem de serviço não encontrada'.hardcoded,
                      fontStyle: FontStyle.italic,
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
    final pauseCubit = context.read<PauseWorkflowCubit>();
    final serviceProvidersCubit = context.read<ServiceProvidersCubit>();

    useEffect(() {
      pauseCubit.loadPauseRequests(workOrder.id);
      if (workOrder.serviceProviderCompanyId != null) {
        serviceProvidersCubit.ensureProfilesLoaded(
          workOrder.serviceProviderCompanyId!,
        );
      }
      return null;
    }, [workOrder.id, workOrder.serviceProviderCompanyId]);

    observeRunning([
      ObservedLoadingTarget(
        context.read<WorkOrderDetailsCubit>(),
        sections: const {
          WorkOrderDetailsSections.deleteWorkOrder,
          WorkOrderDetailsSections.restoreWorkOrder,
          WorkOrderDetailsSections.changeStatus,
          WorkOrderDetailsSections.resumeWork,
        },
      ),
      ObservedLoadingTarget(
        pauseCubit,
        sections: const {
          PauseWorkflowSections.requestPause,
          PauseWorkflowSections.reviewPause,
          PauseWorkflowSections.requestCompletion,
          PauseWorkflowSections.reviewCompletion,
        },
      ),
    ]);

    Future<void> onRefresh() async {
      await Future.wait([
        context.read<WorkOrderDetailsCubit>().loadWorkOrder(workOrder.id),
        pauseCubit.loadPauseRequests(workOrder.id),
        context.read<AttachmentsCubit>().refreshAttachments(),
        context.read<WorkOrderObservationsCubit>().fetchObservations(
          workOrder.id,
        ),
        if (workOrder.serviceProviderCompanyId != null)
          serviceProvidersCubit.ensureProfilesLoaded(
            workOrder.serviceProviderCompanyId!,
          ),
      ]);
    }

    return BaseScaffold(
      isScrollable: false,
      onRefresh: onRefresh,
      appBar: BaseAppBar(
        title: 'Detalhes da ordem de serviço'.hardcoded,
        actions: [
          if (!workOrder.isDeleted)
            EditAndDeleteIcons(workOrderId: workOrder.id),
        ],
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (workOrder.isDeleted)
            SliverToBoxAdapter(
              child: DeletedWorkOrderBanner(workOrder: workOrder),
            ),
          InfoItems(workOrder: workOrder, onRefresh: onRefresh),
          Attachments(
            // Evidence can be added for as long as the work is being executed —
            // by the provider too, who has no other way in since the edit form
            // is closed to them. The attachment permissions are enforced by the
            // widget itself.
            isWorkOrderActive:
                !workOrder.isDeleted && workOrder.status.acceptsAttachments,
            padding: EdgeInsets.zero,
            workOrderCompanyId: workOrder.companyId,
            autoUpload: true,
          ),
          ObservationsSection(workOrder: workOrder),
          gapSliverH24,
        ],
      ),
      bottomNavigationBar:
          !workOrder.isDeleted && workOrder.status.showsBottomActions
          ? WorkOrderBottomActions(workOrder: workOrder)
          : null,
    );
  }
}
