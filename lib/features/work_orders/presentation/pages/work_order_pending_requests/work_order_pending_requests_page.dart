import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/review_completion_dialog.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/review_pause_dialog.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/title_and_subtitle.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

part './widgets/pending_request_card.dart';

@RoutePage()
class WorkOrderPendingRequestsPage extends StatelessWidget {
  const WorkOrderPendingRequestsPage({
    required this.workOrder,
    required this.currentUserId,
    super.key,
  });

  final WorkOrderEntity workOrder;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<PauseWorkflowCubit>()..loadPauseRequests(workOrder.id),
      child: Builder(
        builder: (context) {
          Future<void> refresh() async {
            await Future.wait([
              context.read<WorkOrdersCubit>().loadWorkOrdersAndChangeRequests(),
              context.read<PauseWorkflowCubit>().loadPauseRequests(
                workOrder.id,
              ),
            ]);
          }

          final pendingRequestsLength = context.select<PauseWorkflowCubit, int>(
            (cubit) => cubit.state.pauseRequests
                .where((e) => e.status == PauseRequestStatus.pending)
                .length,
          );

          return BaseScaffold(
            isScrollable: false,
            onRefresh: refresh,
            appBar: BaseAppBar(
              title:
                  '${pendingRequestsLength > 0 ? pendingRequestsLength : ''} Solicitações pendentes'
                      .hardcoded,
            ),
            body:
                BaseStateView<
                  PauseWorkflowCubit,
                  PauseWorkflowState,
                  List<PauseRequestEntity>
                >(
                  onRetry: refresh,
                  dataSelector: (state) =>
                      state.pauseRequests
                          .where((r) => r.status == PauseRequestStatus.pending)
                          .toList()
                        ..sort((a, b) {
                          final aIsCompletion =
                              a.eventType == PauseEventType.completion;
                          final bIsCompletion =
                              b.eventType == PauseEventType.completion;

                          if (aIsCompletion != bIsCompletion) {
                            return aIsCompletion ? -1 : 1;
                          }

                          return a.createdAt.compareTo(b.createdAt);
                        }),
                  builder: (context, pendingRequests) {
                    return pendingRequests.isEmpty
                        ? Center(
                            child: BaseText.error(
                              'Nenhuma solicitação pendente'.hardcoded,
                            ),
                          )
                        : ResponsiveListFlow(
                            itemCount: pendingRequests.length,
                            itemBuilder: (context, index) {
                              final request = pendingRequests[index];
                              return _PendingRequestCard(
                                request: request,
                                workOrder: workOrder,
                                currentUserId: currentUserId,
                              );
                            },
                          );
                  },
                ),
          );
        },
      ),
    );
  }
}
