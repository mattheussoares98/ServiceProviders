import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/work_order_checklist/work_order_checklist_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/widgets/checklist_item_tile.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

/// The checklist a work order must answer while it is being executed.
///
/// Renders nothing when the order has no template linked, so orders created
/// before checklists existed keep their previous layout.
class WorkOrderChecklistSection extends StatelessWidget {
  const WorkOrderChecklistSection({super.key, required this.workOrder});

  final WorkOrderEntity workOrder;

  @override
  Widget build(BuildContext context) {
    if (workOrder.checklistTemplateId == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    // Answers are only editable while the work is actually being executed;
    // afterwards the section stays as the record of what was answered.
    final isEditable =
        !workOrder.isDeleted && workOrder.status.acceptsAttachments;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
        child:
            BaseStateView<
              WorkOrderChecklistCubit,
              WorkOrderChecklistState,
              WorkOrderChecklistState
            >(
              dataSelector: (state) => state,
              onRetry: () =>
                  context.read<WorkOrderChecklistCubit>().loadChecklist(
                    templateId: workOrder.checklistTemplateId!,
                    workOrderId: workOrder.id,
                  ),
              builder: (context, state) {
                if (state.items.isEmpty) {
                  return BaseText.bodyMedium(
                    'O checklist desta ordem não possui itens'.hardcoded,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ChecklistHeader(state: state),
                    gapH8,
                    for (final item in state.items)
                      IgnorePointer(
                        ignoring: !isEditable,
                        child: ChecklistItemTile(
                          item: item,
                          workOrderId: workOrder.id,
                          response: state.answers[item.id],
                          onChanged: (answer) => context
                              .read<WorkOrderChecklistCubit>()
                              .answerItem(
                                workOrderId: workOrder.id,
                                checklistItemId: item.id,
                                booleanValue: answer.booleanValue,
                                textValue: answer.textValue,
                                numberValue: answer.numberValue,
                                photoUrl: answer.photoUrl,
                                selectedOption: answer.selectedOption,
                              ),
                        ),
                      ),
                  ],
                );
              },
            ),
      ),
    );
  }
}

class _ChecklistHeader extends StatelessWidget {
  const _ChecklistHeader({required this.state});

  final WorkOrderChecklistState state;

  @override
  Widget build(BuildContext context) {
    final pendingRequired = !state.areRequiredItemsCompleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: BaseText.title('Checklist'.hardcoded)),
            BaseText.caption(
              '${state.completedItemsCount}/${state.items.length}',
            ),
          ],
        ),
        gapH4,
        ClipRRect(
          borderRadius: BorderRadius.circular(Sizes.p4),
          child: LinearProgressIndicator(value: state.progress),
        ),
        if (pendingRequired) ...[
          gapH4,
          BaseText.caption(
            'Há itens obrigatórios pendentes'.hardcoded,
            color: context.colorScheme.error,
          ),
        ],
      ],
    );
  }
}
