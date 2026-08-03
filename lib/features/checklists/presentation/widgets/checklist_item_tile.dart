import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_response_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/chip/base_choice_chip.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

part 'checklist_items/checklist_boolean_input.dart';
part 'checklist_items/checklist_number_input.dart';
part 'checklist_items/checklist_photo_input.dart';
part 'checklist_items/checklist_selection_input.dart';
part 'checklist_items/checklist_text_input.dart';

/// Container widget for rendering an interactive checklist item tile.
class ChecklistItemTile extends StatelessWidget {
  const ChecklistItemTile({
    super.key,
    required this.item,
    this.response,
    required this.onChanged,
  });

  final ChecklistItemEntity item;
  final ChecklistItemResponseEntity? response;
  final ValueChanged<ChecklistItemResponseEntity> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Sizes.p4),
      padding: const EdgeInsets.all(Sizes.p12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Sizes.p8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: BaseText.bodyMedium(
                  item.label,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
            ),
            ChecklistItemType.number => ChecklistNumberInput(
              item: item,
              response: response,
              onChanged: onChanged,
            ),
            ChecklistItemType.selection => ChecklistSelectionInput(
              item: item,
              response: response,
              onChanged: onChanged,
            ),
            ChecklistItemType.photo => ChecklistPhotoInput(
              item: item,
              response: response,
              onChanged: onChanged,
            ),
          },
        ],
      ),
    );
  }
}
