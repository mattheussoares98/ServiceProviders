part of '../work_order_pending_requests_page.dart';

class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({
    required this.request,
    required this.workOrder,
    required this.currentUserId,
  });

  final PauseRequestEntity request;
  final WorkOrderEntity workOrder;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final isPauseRequest = request.eventType == PauseEventType.pause;

    final canApprove = context.hasPermission(
      const ActionPermission.workOrderSubAction(
        WorkOrderSubAction.managePendingRequests,
      ),
    );

    final requestedBy = context.read<UsersCubit>().state.users.firstWhereOrNull(
      (e) => e.id == request.requestedById,
    );

    final cardBgColor = isPauseRequest ? Colors.amber[100]! : Colors.blue[100]!;
    final borderColor = isPauseRequest ? Colors.amber[700]! : Colors.blue[700]!;
    final iconColor = isPauseRequest ? Colors.amber[900]! : Colors.blue[900]!;

    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.p8),
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
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Flexible(
                      child: BaseText.bodyLarge(
                        isPauseRequest
                            ? 'Pausa'.hardcoded
                            : 'Conclusão'.hardcoded,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                    Flexible(
                      child: BaseText.bodySmall(
                        request.createdAt.formatDate(.ddMMyyyyHHmm),
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
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
          if (requestedBy != null) ...[
            gapH4,
            TitleAndSubtitle(
              title: 'Solicitado por'.hardcoded,
              subtitle: requestedBy.name,
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
                    await context.read<PauseWorkflowCubit>().loadPauseRequests(
                      workOrder.id,
                      status: PauseRequestStatus.pending,
                    );

                    if (!isPauseRequest && context.mounted) {
                      await context
                          .read<WorkOrdersCubit>()
                          .loadWorkOrdersAndChangeRequests();
                    }
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
