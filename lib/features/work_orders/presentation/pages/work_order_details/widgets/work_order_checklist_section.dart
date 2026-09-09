import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/work_order_checklist/work_order_checklist_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/widgets/checklist_item_tile.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_rich_text.dart';
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

  void _openChecklistModal(
    BuildContext context,
    WorkOrderChecklistState state,
    bool isEditable,
  ) {
    final cubit = context.read<WorkOrderChecklistCubit>();
    showModalPage<void>(
      BlocProvider.value(
        value: cubit,
        child: _WorkOrderChecklistModal(
          workOrder: workOrder,
          isEditable: isEditable,
        ),
      ),
      context,
      initialChildSize: 0.9,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (workOrder.checklistTemplateId == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    // Answers are only editable while the work is actually being executed;
    // afterwards the section stays as the record of what was answered.
    final isEditable =
        !workOrder.isDeleted && workOrder.status.acceptsAttachments;

    return BaseStateView<
      WorkOrderChecklistCubit,
      WorkOrderChecklistState,
      WorkOrderChecklistState
    >(
      isSliver: true,
      dataSelector: (state) => state,
      onRetry: () => context.read<WorkOrderChecklistCubit>().loadChecklist(
        templateId: workOrder.checklistTemplateId!,
        workOrderId: workOrder.id,
      ),
      builder: (context, state) {
        if (state.items.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
              child: BaseText.bodyMedium(
                'O checklist desta ordem não possui itens'.hardcoded,
              ),
            ),
          );
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
            child: Card(
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () => _openChecklistModal(context, state, isEditable),
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.p12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ChecklistHeader(
                          completedCount: state.completedItemsCount,
                          totalCount: state.items.length,
                          progress: state.progress,
                          pendingRequired: !state.areRequiredItemsCompleted,
                        ),
                      ),
                      gapW12,
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WorkOrderChecklistModal extends StatelessWidget {
  const _WorkOrderChecklistModal({
    required this.workOrder,
    required this.isEditable,
  });

  final WorkOrderEntity workOrder;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkOrderChecklistCubit, WorkOrderChecklistState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChecklistHeader(
                completedCount: state.completedItemsCount,
                totalCount: state.items.length,
                progress: state.progress,
                pendingRequired: !state.areRequiredItemsCompleted,
              ),
              gapH12,
              Expanded(
                child: IgnorePointer(
                  ignoring: !isEditable,
                  child: ResponsiveListFlow(
                    padding: const EdgeInsets.only(bottom: Sizes.p24),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _ChecklistItemEntry(
                        key: ValueKey(item.id),
                        item: item,
                        workOrder: workOrder,
                        isEditable: isEditable,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChecklistItemEntry extends StatelessWidget {
  const _ChecklistItemEntry({
    super.key,
    required this.item,
    required this.workOrder,
    required this.isEditable,
  });

  final ChecklistItemEntity item;
  final WorkOrderEntity workOrder;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    if (!isEditable) {
      return BaseRichText(
        texts: [
          BaseText(item.label),
          if (item.isRequired) const BaseText('*', color: Colors.red),
        ],
      );
    }

    return BlocSelector<
      WorkOrderChecklistCubit,
      WorkOrderChecklistState,
      ChecklistAnswerEntity?
    >(
      selector: (state) => state.answers[item.id],
      builder: (context, answer) {
        return ChecklistItemTile(
          item: item,
          workOrderId: workOrder.id,
          response: answer,
          onChanged: (newAnswer) =>
              context.read<WorkOrderChecklistCubit>().answerItem(
                workOrderId: workOrder.id,
                checklistItemId: item.id,
                booleanValue: newAnswer.booleanValue,
                textValue: newAnswer.textValue,
                numberValue: newAnswer.numberValue,
                photoUrl: newAnswer.photoUrl,
                selectedOption: newAnswer.selectedOption,
                selectedOptions: newAnswer.selectedOptions,
              ),
        );
      },
    );
  }
}

class _ChecklistHeader extends StatelessWidget {
  const _ChecklistHeader({
    required this.completedCount,
    required this.totalCount,
    required this.progress,
    required this.pendingRequired,
  });

  final int completedCount;
  final int totalCount;
  final double progress;
  final bool pendingRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: BaseText.title('Checklist'.hardcoded)),
            BaseText.caption('$completedCount/$totalCount'),
          ],
        ),
        gapH4,
        ClipRRect(
          borderRadius: BorderRadius.circular(Sizes.p4),
          child: LinearProgressIndicator(value: progress),
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
