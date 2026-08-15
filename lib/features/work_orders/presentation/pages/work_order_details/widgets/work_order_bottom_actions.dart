import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_sub_action.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/request_completion_fields.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/request_pause_fields.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class WorkOrderBottomActions extends StatelessWidget {
  const WorkOrderBottomActions({
    required this.workOrder,
    required this.currentUserId,
    required this.pauseCubit,
    super.key,
  });

  final WorkOrderEntity workOrder;
  final String currentUserId;
  final PauseWorkflowCubit pauseCubit;
  //TODO read this entire file
  @override
  Widget build(BuildContext context) {
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
              onOkPressed: () => context.read<WorkOrdersCubit>().resumeWork(
                workOrder: workOrder,
                currentUserId: currentUserId,
                pauseCubit: pauseCubit,
              ),
            );
          },
        ),
      );
    }

    if (workOrder.status.isRunning) {
      final isPendingConclusion = workOrder.status.isPendingConclusionApproval;
      final canApproveCompletion = context.hasPermission(
        const ActionPermission.workOrderSubAction(
          WorkOrderSubAction.approveCompletion,
        ),
      );

      return _BottomBar(
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Pausar'.hardcoded,
                onTap: () async {
                  final result = await showModalPage<bool>(
                    RequestPauseFields(
                      companyId: workOrder.companyId,
                      workOrderId: workOrder.id,
                      currentUserId: currentUserId,
                    ),
                    context,
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
            if (!isPendingConclusion)
              Expanded(
                child: BaseButton(
                  text: canApproveCompletion
                      ? 'Concluir'.hardcoded
                      : 'Solicitar conclusão'.hardcoded,
                  onTap: () async {
                    if (canApproveCompletion) {
                      await context.read<WorkOrdersCubit>().concludeDirectly(
                        workOrder: workOrder,
                      );
                      return;
                    }

                    final result = await showModalPage<bool>(
                      RequestCompletionFields(
                        companyId: workOrder.companyId,
                        workOrderId: workOrder.id,
                        currentUserId: currentUserId,
                      ),
                      context,
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
