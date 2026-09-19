import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';

void main() {
  group('DateTimeExtension', () {
    test('formatDate converts UTC DateTime to local timezone before formatting', () {
      final utcDate = DateTime.utc(2026, 9, 19, 15, 30);
      final localDate = utcDate.toLocal();
      final expectedFormatted = DateFormat('dd/MM/yyyy HH:mm').format(localDate);

      final result = utcDate.formatDate(DateFormatType.ddMMyyyyHHmm);

      expect(result, equals(expectedFormatted));
    });

    test('toIsoUtcString converts to ISO 8601 UTC string', () {
      final localDate = DateTime(2026, 9, 19, 15, 30);
      final result = localDate.toIsoUtcString();

      expect(result, equals(localDate.toUtc().toIso8601String()));
    });
  });
}
