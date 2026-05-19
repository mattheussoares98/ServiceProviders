import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/utils/validators/string_validator.dart';

class NumberValidator implements StringValidator {
  NumberValidator({
    required this.allowDecimal,
    this.maxDecimalHouses = 2,
    this.needsBeGreaterThanZero = true,
    this.allowEmptyValue,
  });
  final bool allowDecimal;
  final int? maxDecimalHouses;
  final bool needsBeGreaterThanZero;
  final bool? allowEmptyValue;

  String? _errorMessage;

  @override
  String get errorMessage => _errorMessage ?? '';

  @override
  bool isValid(String? value) {
    if ((allowEmptyValue ?? false) && (value == null || value.trim().isEmpty)) {
      return true;
    }

    if (value == null || value.trim().isEmpty) {
      _errorMessage = 'Campo obrigatório'.hardcoded;
      return false;
    }

    if (RegExp(r'[^\d,.]').hasMatch(value)) {
      _errorMessage = 'Formato inválido'.hardcoded;
      return false;
    }

    final separatorCount =
        value.split('.').length - 1 + value.split(',').length - 1;
    if (separatorCount > 1) {
      _errorMessage = 'Formato inválido'.hardcoded;
      return false;
    }

    // 1. Sanitize the input string to a universal format (e.g., '1234.56')
    // This handles both '1.234,56' (pt-BR) and '1,234.56' (en-US)
    final sanitizedValue = value
        .replaceAll(RegExp(r'[^\d,.]'), '') // Keep only digits, commas, dots
        .replaceAll(',', '.'); // Convert comma to dot

    // Remove all dots that are not the last one (to clear thousand separators)
    final normalizedValue = sanitizedValue.replaceAll(
      RegExp(r'\.(?=[^.]*\.)'),
      '',
    );

    // 2. Try to parse the normalized string
    final number = num.tryParse(normalizedValue);

    if (number == null) {
      _errorMessage = 'Formato inválido'.hardcoded;
      return false;
    }

    // 3. If decimals are not allowed, check if the number is an integer
    if (!allowDecimal && number != number.truncate()) {
      _errorMessage = 'Apenas números inteiros'.hardcoded;
      return false;
    }

    if (maxDecimalHouses != null && normalizedValue.contains('.')) {
      // Get the part of the string after the decimal point
      final decimalPart = normalizedValue.split('.').last;
      if (decimalPart.length > maxDecimalHouses!) {
        _errorMessage = 'Máx $maxDecimalHouses casas decimais'.hardcoded;
        return false;
      }
    }

    if (needsBeGreaterThanZero && number <= 0) {
      _errorMessage = 'Deve ser maior que zero'.hardcoded;
      return false;
    }

    // 4. If all checks pass, the value is valid
    _errorMessage = null;
    return true;
  }
}
