import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/shared_ui/themes/theme.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/chip/base_choice_chip.dart';

void main() {
  group('BaseChoiceChip Widget Tests', () {
    testWidgets('uses correct text color in dark theme when unselected', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: Scaffold(
            body: BaseChoiceChip<bool>(
              items: const [true, false],
              selections: const [true],
              itemLabelBuilder: (val) => val ? 'Conforme' : 'Não conforme',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final unselectedChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Não conforme'),
      );
      final selectedChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Conforme'),
      );

      expect(selectedChip.labelStyle?.color, Colors.white);
      expect(
        unselectedChip.labelStyle?.color,
        darkTheme.colorScheme.onSurface,
      );
    });

    testWidgets('uses correct text color in light theme when unselected', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: BaseChoiceChip<bool>(
              items: const [true, false],
              selections: const [true],
              itemLabelBuilder: (val) => val ? 'Conforme' : 'Não conforme',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final unselectedChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Não conforme'),
      );
      final selectedChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Conforme'),
      );

      expect(selectedChip.labelStyle?.color, Colors.white);
      expect(
        unselectedChip.labelStyle?.color,
        lightTheme.colorScheme.onSurface,
      );
    });
  });
}
