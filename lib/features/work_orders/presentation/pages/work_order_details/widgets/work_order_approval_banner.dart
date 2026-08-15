import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/review_completion_dialog.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/review_pause_dialog.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/title_and_subtitle.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class WorkOrderApprovalBanner extends HookWidget {
  const WorkOrderApprovalBanner({
    required this.workOrder,
    required this.pauseRequests,
    required this.currentUserId,
    required this.onRefresh,
    super.key,
  });
  //TODO check this entire code
  final WorkOrderEntity workOrder;
  final List<PauseRequestEntity> pauseRequests;
  final String currentUserId;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (workOrder.status != WorkOrderStatus.pendingPauseApproval &&
        workOrder.status != WorkOrderStatus.pendingConclusionApproval) {
      return const SizedBox.shrink();
    }

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

    final isPauseApproval =
        workOrder.status == WorkOrderStatus.pendingPauseApproval;

    // Find the latest pending request for this type
    final pendingRequest = pauseRequests
        .where(
          (r) =>
              r.status == PauseRequestStatus.pending &&
              (isPauseApproval
                  ? r.eventType == PauseEventType.pause
                  : r.eventType == PauseEventType.completion),
        )
        .firstOrNull;

    final bannerColor = isPauseApproval
        ? Colors.amber[100]!
        : Colors.blue[100]!;
    final borderColor = isPauseApproval
        ? Colors.amber[700]!
        : Colors.blue[700]!;
    final iconColor = isPauseApproval ? Colors.amber[900]! : Colors.blue[900]!;

    final title = isPauseApproval
        ? 'Pausa pendente de aprovação'.hardcoded
        : 'Conclusão pendente de aprovação'.hardcoded;

    final canApprove = isPauseApproval ? canApprovePause : canApproveCompletion;

    return Container(
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlatformIcon(
                materialIcon: isPauseApproval
                    ? Icons.pause_circle_filled
                    : Icons.task_alt,
                cupertinoIcon: isPauseApproval
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
            ],
          ),
          if (pendingRequest?.customReason != null) ...[
            gapH8,
            TitleAndSubtitle(
              title: 'Motivo'.hardcoded,
              subtitle: pendingRequest!.customReason,
              titleColor: Colors.black,
              subtitleColor: Colors.black,
            ),
          ],
          if (pendingRequest?.responsibility != null) ...[
            gapH4,
            TitleAndSubtitle(
              title: 'Responsabilidade'.hardcoded,
              subtitle: pendingRequest!.responsibility!.label,
              titleColor: Colors.black,
              subtitleColor: Colors.black,
            ),
          ],
          if (canApprove && pendingRequest != null) ...[
            gapH12,
            Align(
              alignment: Alignment.centerRight,
              child: BaseButton(
                text: isPauseApproval
                    ? 'Revisar pausa'.hardcoded
                    : 'Revisar conclusão'.hardcoded,
                onTap: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      if (isPauseApproval) {
                        return ReviewPauseDialog(
                          pauseRequest: pendingRequest,
                          currentUserId: currentUserId,
                        );
                      } else {
                        return ReviewCompletionDialog(
                          pauseRequest: pendingRequest,
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
