import 'package:flutter/services.dart';

class CreditCardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // 1. Single pass to extract digits and count digits before cursor
    final selectionEnd = newValue.selection.end;
    final digitsOnlyBuffer = StringBuffer();
    var digitsBeforeCursor = 0;

    for (var i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      // Faster than Regex: 48 is '0', 57 is '9'
      final isDigit = codeUnit >= 48 && codeUnit <= 57;

      if (isDigit) {
        digitsOnlyBuffer.write(text[i]);
        if (i < selectionEnd) {
          digitsBeforeCursor++;
        }
      }
    }

    final digitsOnly = digitsOnlyBuffer.toString();
    if (digitsOnly.length > 16) {
      return oldValue;
    }

    // 2. Build formatted string and calculate new selection index in one pass
    final formattedBuffer = StringBuffer();
    var newSelectionIndex = 0;

    for (var i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formattedBuffer.write('.');
        // If we added a dot before reaching the cursor's target digit count, advance selection
        if (i < digitsBeforeCursor) {
          newSelectionIndex++;
        }
      }
      formattedBuffer.write(digitsOnly[i]);
      if (i < digitsBeforeCursor) {
        newSelectionIndex++;
      }
    }

    final formattedText = formattedBuffer.toString();

    // 3. UX: If the cursor lands exactly before a dot, push it after the dot
    if (newSelectionIndex < formattedText.length &&
        formattedText[newSelectionIndex] == '.') {
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
