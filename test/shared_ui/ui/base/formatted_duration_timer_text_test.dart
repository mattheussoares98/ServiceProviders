import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/formatted_duration_timer_text.dart';

void main() {
  group('FormattedDurationTimerText', () {
    test('formatDuration formats seconds and minutes correctly', () {
      expect(
        FormattedDurationTimerText.formatDuration(const Duration(seconds: 45)),
        '0m e 45s',
      );

      expect(
        FormattedDurationTimerText.formatDuration(
          const Duration(minutes: 5, seconds: 12),
        ),
        '5m e 12s',
      );
    });

    test('formatDuration formats hours correctly', () {
      expect(
        FormattedDurationTimerText.formatDuration(
          const Duration(hours: 2, minutes: 15, seconds: 30),
        ),
        '2h, 15m e 30s',
      );
    });

    test('formatDuration formats days and weeks correctly', () {
      expect(
        FormattedDurationTimerText.formatDuration(
          const Duration(days: 3, hours: 4, minutes: 10, seconds: 5),
        ),
        '3 dias, 4h, 10m e 5s',
      );

      expect(
        FormattedDurationTimerText.formatDuration(
          const Duration(days: 10, hours: 2, seconds: 1),
        ),
        '1 sem, 3 dias, 2h, 0m e 1s',
      );
    });

    testWidgets('renders initial static duration when not running', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormattedDurationTimerText(
              initialAccumulatedSeconds: 125,
              isRunning: false,
            ),
          ),
        ),
      );

      expect(find.text('2m e 5s'), findsOneWidget);
    });
  });
}
