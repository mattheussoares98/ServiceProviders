import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_sub_action.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_details/work_order_details_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/widgets/request_completion_fields.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/widgets/request_pause_fields.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class WorkOrderBottomActions extends StatelessWidget {
  const WorkOrderBottomActions({required this.workOrder, super.key});

  final WorkOrderEntity workOrder;
  @override
  Widget build(BuildContext context) {
    if (workOrder.status.isOpen) {
      return _BottomBar(
        child: BaseButton(
          text: 'Iniciar trabalho'.hardcoded,
          onTap: () {
            showAlertDialog(
              context: context,
              title: 'Iniciar trabalho'.hardcoded,
              contentText: 'Deseja realmente iniciar o trabalho?'.hardcoded,
              defaultActionText: 'Sim'.hardcoded,
              cancelActionText: 'Não'.hardcoded,
              onOkPressed: () =>
                  context.read<WorkOrderDetailsCubit>().changeWorkOrderStatus(
                    workOrder: workOrder,
                    status: WorkOrderStatus.inProgress,
                  ),
            );
          },
        ),
      );
    }

    if (workOrder.status.isPaused ||
        workOrder.status.isPendingConclusionApproval) {
      return _BottomBar(
        child: BaseButton(
          text: 'Retomar trabalho'.hardcoded,
          onTap: () {
            showAlertDialog(
              context: context,
              title: 'Retomar trabalho'.hardcoded,
              contentText: 'Deseja realmente retomar o trabalho?'.hardcoded,
              defaultActionText: 'Sim'.hardcoded,
              cancelActionText: 'Não'.hardcoded,
              onOkPressed: () => context.read<WorkOrderDetailsCubit>().resumeWork(
                workOrder: workOrder,
                currentUserId: context.read<SessionCubit>().state.user.id,
                pauseCubit: context.read<PauseWorkflowCubit>(),
              ),
            );
          },
        ),
      );
    }

    if (workOrder.status.isRunning) {
      final isPendingConclusion = workOrder.status.isPendingConclusionApproval;
      final canmanagePendingRequests = context.hasPermission(
        const ActionPermission.workOrderSubAction(
          WorkOrderSubAction.managePendingRequests,
        ),
      );

      return _BottomBar(
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Pausar'.hardcoded,
                onTap: () async {
                  await showModalPage<void>(
                    RequestPauseFields(workOrderId: workOrder.id),
                    context,
                  );
                },
              ),
            ),
            gapW12,
            if (!isPendingConclusion)
              Expanded(
                child: BaseButton(
                  text: canmanagePendingRequests
                      ? 'Concluir'.hardcoded
                      : 'Solicitar conclusão'.hardcoded,
                  onTap: () async {
                    if (canmanagePendingRequests) {
                      final ok = await showAlertDialog(
                        context: context,
                        title: 'Concluir'.hardcoded,
                        contentText:
                            'Deseja realmente concluir a ordem de serviço?'
                                .hardcoded,
                        defaultActionText: 'Sim'.hardcoded,
                        cancelActionText: 'Não'.hardcoded,
                      );
                      if (ok == true && context.mounted) {
                        await context.read<WorkOrderDetailsCubit>().concludeDirectly(
                          workOrder: workOrder,
                        );
                      }
                      return;
                    }

                    await showModalPage<void>(
                      RequestCompletionFields(workOrderId: workOrder.id),
                      context,
                    );
                  },
                ),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
      child: child,
    );
  }
}
