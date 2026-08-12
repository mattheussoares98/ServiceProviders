import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/themes/theme.dart' as theme;
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

/// PERFORMANCE: Choice chips layout rendered inside a Wrap widget.
class BaseChoiceChip<T> extends StatelessWidget {
  const BaseChoiceChip({
    super.key,
    required this.items,
    required this.onChanged,
    required this.itemLabelBuilder,
    this.itemColorBuilder,
    this.allowNullSelection = false,
    required this.selections,
  });

  final List<T> items;
  final List<T> selections;
  //error because of the dart version
  // ignore: unsafe_variance
  final ValueChanged<T> onChanged;
  final String Function(T item) itemLabelBuilder;
  final Color? Function(T item)? itemColorBuilder;
  final bool allowNullSelection;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Wrap(
        key: const ValueKey('wrap'),
        spacing: Sizes.p8,
        runSpacing: Sizes.p8,
        alignment: WrapAlignment.center,
        children: items.map((item) {
          final isSelected = selections.contains(item);
          final color =
              itemColorBuilder?.call(item) ?? context.theme.colorScheme.primary;

          return ChoiceChip(
            key: ValueKey(item),
            label: BaseText(itemLabelBuilder(item)),
            selected: isSelected,
            onSelected: (selected) {
              if (allowNullSelection) {
                onChanged(item);
              } else if (selected) {
                onChanged(item);
              }
            },
            selectedColor: color,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            ),
          );
        }).toList(),
      ),
    );
  }
}
