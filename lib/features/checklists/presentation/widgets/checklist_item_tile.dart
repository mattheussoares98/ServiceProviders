import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/domain/entities/file_extension.dart';
import 'package:o_jogo_da_obra/core/utils/debounce_time.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/work_order_checklist/work_order_checklist_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_checkbox.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/chip/base_choice_chip.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/min_length_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/number_validator.dart';

part 'checklist_items/checklist_boolean_input.dart';
part 'checklist_items/checklist_documentation_input.dart';
part 'checklist_items/checklist_evidence_input.dart';
part 'checklist_items/checklist_multi_selection_input.dart';
part 'checklist_items/checklist_number_input.dart';
part 'checklist_items/checklist_photo_input.dart';
part 'checklist_items/checklist_selection_input.dart';
part 'checklist_items/checklist_text_input.dart';

/// Container widget for rendering an interactive checklist item tile.
class ChecklistItemTile extends HookWidget {
  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.workOrderId,
    this.response,
    required this.onChanged,
  });

  final ChecklistItemEntity item;

  /// Needed by the evidence types, which upload an attachment against the order
  /// before the answer that would carry these ids exists.
  final String workOrderId;
  final ChecklistAnswerEntity? response;
  final ValueChanged<ChecklistAnswerEntity> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final formKey = useMemoized(GlobalKey<FormState>.new);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Sizes.p4),
      padding: const EdgeInsets.all(Sizes.p12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Sizes.p8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Wrap(
              runSpacing: Sizes.p8,
              spacing: Sizes.p8,
              alignment: .spaceBetween,
              children: [
                BaseText.bodyMedium(item.label, fontWeight: FontWeight.w600),
                if (item.isRequired)
                  Padding(
                    padding: const EdgeInsets.only(left: Sizes.p4),
                    child: BaseText.caption(
                      '* obrigatório'.hardcoded,
                      color: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
            gapH8,
            switch (item.type) {
              ChecklistItemType.boolean => ChecklistBooleanInput(
                item: item,
                response: response,
                onChanged: onChanged,
              ),
              ChecklistItemType.text => ChecklistTextInput(
                item: item,
                response: response,
                onChanged: onChanged,
                formKey: formKey,
              ),
              ChecklistItemType.number => ChecklistNumberInput(
                item: item,
                response: response,
                onChanged: onChanged,
                formKey: formKey,
              ),
              ChecklistItemType.selection => ChecklistSelectionInput(
                item: item,
                response: response,
                onChanged: onChanged,
              ),
              ChecklistItemType.multiSelection => ChecklistMultiSelectionInput(
                item: item,
                response: response,
                onChanged: onChanged,
              ),
              ChecklistItemType.photo => ChecklistPhotoInput(
                item: item,
                workOrderId: workOrderId,
                response: response,
                onChanged: onChanged,
              ),
              ChecklistItemType.documentation => ChecklistDocumentationInput(
                item: item,
                workOrderId: workOrderId,
                response: response,
                onChanged: onChanged,
              ),
            },
          ],
        ),
      ),
    );
  }
}
