import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_sub_action.dart';
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
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/title_and_subtitle.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

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
    final pauseCubit = GetIt.I<PauseWorkflowCubit>();
    //TODO check this entire page
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
    return BlocProvider(
      create: (context) => pauseCubit..loadPauseRequests(workOrder.id),
      child: BlocBuilder<PauseWorkflowCubit, PauseWorkflowState>(
        builder: (context, state) {
          final pendingRequests = state.pauseRequests
              .where((r) => r.status == PauseRequestStatus.pending)
              .toList();

          return BaseScaffold(
            isScrollable: false,
            onRefresh: () async {
              await context
                  .read<WorkOrdersCubit>()
                  .loadWorkOrdersAndChangeRequests();
              await pauseCubit.loadPauseRequests(workOrder.id);
            },
            appBar: BaseAppBar(title: 'Solicitações pendentes'.hardcoded),
            body: pendingRequests.isEmpty
                ? BaseText.error(
                    'Nenhuma solicitação pendente'.hardcoded,
                    // subtitle:
                    //     'Todas as solicitações desta ordem de serviço foram revisadas.'
                    //         .hardcoded,
                    // platformIcon: const PlatformIcon(
                    //   materialIcon: Icons.task_alt,
                    //   cupertinoIcon: CupertinoIcons.check_mark_circled,
                    // ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(Sizes.p16),
                    itemCount: pendingRequests.length,
                    separatorBuilder: (_, _) => gapH16,
                    itemBuilder: (context, index) {
                      final request = pendingRequests[index];
                      return _PendingRequestCard(
                        request: request,
                        workOrder: workOrder,
                        currentUserId: currentUserId,
                        onRefresh: () {
                          context
                              .read<WorkOrdersCubit>()
                              .loadWorkOrdersAndChangeRequests();
                          pauseCubit.loadPauseRequests(workOrder.id);
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

class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({
    required this.request,
    required this.workOrder,
    required this.currentUserId,
    required this.onRefresh,
  });

  final PauseRequestEntity request;
  final WorkOrderEntity workOrder;
  final String currentUserId;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final isPauseRequest = request.eventType == PauseEventType.pause;

    final canApprove = isPauseRequest
        ? context.hasPermission(
            const ActionPermission.workOrderSubAction(
              WorkOrderSubAction.approvePause,
            ),
          )
        : context.hasPermission(
            const ActionPermission.workOrderSubAction(
              WorkOrderSubAction.approveCompletion,
            ),
          );

    final cardBgColor = isPauseRequest ? Colors.amber[100]! : Colors.blue[100]!;
    final borderColor = isPauseRequest ? Colors.amber[700]! : Colors.blue[700]!;
    final iconColor = isPauseRequest ? Colors.amber[900]! : Colors.blue[900]!;

    final title = isPauseRequest
        ? 'Solicitação de pausa'.hardcoded
        : 'Solicitação de conclusão'.hardcoded;

    return Container(
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlatformIcon(
                materialIcon: isPauseRequest
                    ? Icons.pause_circle_filled
                    : Icons.task_alt,
                cupertinoIcon: isPauseRequest
                    ? CupertinoIcons.pause_circle_fill
                    : CupertinoIcons.check_mark_circled,
                color: iconColor,
              ),
              gapW8,
              Expanded(
                child: BaseText.bodyLarge(
                  title,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              BaseText.bodySmall(
                request.createdAt.formatDate(),
                color: Colors.black54,
              ),
            ],
          ),
          if (request.customReason != null &&
              request.customReason!.isNotEmpty) ...[
            gapH8,
            TitleAndSubtitle(
              title: 'Motivo'.hardcoded,
              subtitle: request.customReason,
              titleColor: Colors.black,
              subtitleColor: Colors.black,
            ),
          ],
          if (request.responsibility != null) ...[
            gapH4,
            TitleAndSubtitle(
              title: 'Responsabilidade'.hardcoded,
              subtitle: request.responsibility!.label,
              titleColor: Colors.black,
              subtitleColor: Colors.black,
            ),
          ],
          if (request.observation != null &&
              request.observation!.isNotEmpty) ...[
            gapH4,
            TitleAndSubtitle(
              title: 'Observação'.hardcoded,
              subtitle: request.observation,
              titleColor: Colors.black,
              subtitleColor: Colors.black,
            ),
          ],
          if (canApprove) ...[
            gapH12,
            Align(
              alignment: Alignment.centerRight,
              child: BaseButton(
                text: isPauseRequest
                    ? 'Revisar pausa'.hardcoded
                    : 'Revisar conclusão'.hardcoded,
                onTap: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      if (isPauseRequest) {
                        return ReviewPauseDialog(
                          pauseRequest: request,
                          currentUserId: currentUserId,
                        );
                      } else {
                        return ReviewCompletionDialog(
                          pauseRequest: request,
                          currentUserId: currentUserId,
                        );
                      }
                    },
                  );

                  if (result != null && context.mounted) {
                    onRefresh();
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
