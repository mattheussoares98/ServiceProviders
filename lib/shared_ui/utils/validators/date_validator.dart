import 'package:intl/intl.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/string_validator.dart';

class DateValidator implements StringValidator {
  DateValidator({
    required this.minimumDate,
    required this.maximumDate,
    this.allowEmptyDate,
    this.includeDay = true,
  });
  final DateTime minimumDate;
  final DateTime maximumDate;
  final bool? allowEmptyDate;
  final bool includeDay;

  @override
  String get errorMessage => _errorMessage.hardcoded;
  String _errorMessage = '';

  List<DateFormat> get _acceptedFormats => [
    if (includeDay) DateFormat('dd/MM/yyyy') else DateFormat('MM/yyyy'),
  ];

  @override
  bool isValid(String? value) {
    if ((allowEmptyDate ?? false) && (value == null || value.isEmpty)) {
      return true;
    } else if (value == null || value.isEmpty) {
      return false;
    }

    DateTime? parsedDate;

    for (final format in _acceptedFormats) {
      try {
        parsedDate = format.parseStrict(value, true);
        break;
      } catch (e) {
        continue;
      }
    }

    if (parsedDate == null) {
      _errorMessage = 'Data inválida'.hardcoded;
      return false;
    }

    // Normalization logic
    DateTime normalizedParsedDate;
    DateTime normalizedStartDate;
    DateTime normalizedEndDate;

    if (includeDay) {
      normalizedParsedDate = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );
      normalizedStartDate = DateTime(
        minimumDate.year,
        minimumDate.month,
        minimumDate.day,
      );
      normalizedEndDate = DateTime(
        maximumDate.year,
        maximumDate.month,
        maximumDate.day,
      );
    } else {
      // For MM/YYYY, we only care about Year and Month.
      // To allow the current month to be valid, we compare based on the 1st day of the month.
      normalizedParsedDate = DateTime(parsedDate.year, parsedDate.month);
      normalizedStartDate = DateTime(minimumDate.year, minimumDate.month);
      normalizedEndDate = DateTime(maximumDate.year, maximumDate.month);
    }

    if (normalizedParsedDate.isBefore(normalizedStartDate) ||
        normalizedParsedDate.isAfter(normalizedEndDate)) {
      final formatter = DateFormat(includeDay ? 'dd/MM/yyyy' : 'MM/yyyy');
      _errorMessage =
          'Período inválido. ${formatter.format(minimumDate)} ~ ${formatter.format(maximumDate)}'
              .hardcoded;
      return false;
    }

    return true;
  }
}
