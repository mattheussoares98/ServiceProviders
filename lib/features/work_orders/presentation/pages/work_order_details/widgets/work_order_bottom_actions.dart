import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/request_completion_fields.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/request_pause_fields.dart';
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
    if (workOrder.status == WorkOrderStatus.inProgress) {
      return Container(
        padding: const EdgeInsets.all(Sizes.p16),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
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
                    RequestPauseFields(
                      companyId: workOrder.companyId,
                      workOrderId: workOrder.id,
                      currentUserId: currentUserId,
                    ),
                    context,
                  );

                  if (result == true && context.mounted) {
                    await context.read<WorkOrdersCubit>().changeWorkOrderStatus(
                      workOrder: workOrder,
                      status: WorkOrderStatus.onHold,
                    );
                    if (context.mounted) {
                      unawaited(
                        context
                            .read<WorkOrdersCubit>()
                            .loadWorkOrdersAndChangeRequests(),
                      );
                    }
                  }
                },
              ),
            ),
            gapW12,
            Expanded(
              child: BaseButton(
                text: 'Solicitar conclusão'.hardcoded,
                onTap: () async {
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

    if (workOrder.status == WorkOrderStatus.onHold) {
      return Container(
        padding: const EdgeInsets.all(Sizes.p16),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BaseButton(
          text: 'Retomar trabalho'.hardcoded,
          onTap: () async {
            final activePause = pauseCubit.activePauseRequest;
            if (activePause != null) {
              final success = await context
                  .read<WorkOrdersCubit>()
                  .resumePausedWorkOrder(
                    workOrder: workOrder,
                    currentUserId: currentUserId,
                    pauseId: activePause.id,
                  );

              if (success) {
                unawaited(pauseCubit.loadPauseRequests(workOrder.id));
              }
            } else {
              await context.read<WorkOrdersCubit>().changeWorkOrderStatus(
                workOrder: workOrder,
                status: WorkOrderStatus.inProgress,
              );
            }
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
