import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

/// Editable list of the choices offered by a `selection` checklist item.
class ChecklistItemOptionsField extends HookWidget {
  const ChecklistItemOptionsField({
    super.key,
    required this.options,
    required this.onChanged,
  });

  final List<String> options;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    void addOption() {
      final value = controller.text.trim();
      if (value.isEmpty || options.contains(value)) return;
      onChanged([...options, value]);
      controller.clear();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BaseText.caption('Opções *'.hardcoded),
        gapH4,
        Row(
          children: [
            Expanded(
              child: BaseTextFormField(
                controller: controller,
                hintText: 'Adicione uma opção'.hardcoded,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => addOption(),
                maxLength: 500,
              ),
            ),
            BaseIconButton(
              onPressed: addOption,
              platformIcon: const PlatformIcon(
                materialIcon: Icons.add,
                cupertinoIcon: CupertinoIcons.add,
              ),
            ),
          ],
        ),
        if (options.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Sizes.p4),
            child: BaseText.caption(
              'Informe ao menos uma opção'.hardcoded,
              color: context.colorScheme.error,
            ),
          )
        else
          Wrap(
            spacing: Sizes.p8,
            children: [
              for (final option in options)
                Chip(
                  label: BaseText.bodyMedium(option),
                  onDeleted: () => onChanged(
                    options.where((value) => value != option).toList(),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
