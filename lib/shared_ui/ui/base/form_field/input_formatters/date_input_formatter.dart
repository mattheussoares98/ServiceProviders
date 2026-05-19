import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  DateInputFormatter({this.includeDay = true});
  final bool includeDay;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }
    // 1. Extract digits and count digits before cursor in one pass
    final selectionEnd = newValue.selection.end;
    final digitsBuffer = StringBuffer();
    var digitsBeforeCursor = 0;

    for (var i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      final isDigit = codeUnit >= 48 && codeUnit <= 57;

      if (isDigit) {
        digitsBuffer.write(text[i]);
        if (i < selectionEnd) {
          digitsBeforeCursor++;
        }
      }
    }

    final digitsOnly = digitsBuffer.toString();
    final maxDigits = includeDay ? 8 : 6;

    if (digitsOnly.length > maxDigits) {
      return oldValue;
    }

    // 2. Build formatted string and calculate new selection index
    final formattedBuffer = StringBuffer();
    var newSelectionIndex = 0;

    for (var i = 0; i < digitsOnly.length; i++) {
      // Add slash at the correct positions
      // MM/YYYY: slash after 2nd digit (index 2)
      // DD/MM/YYYY: slash after 2nd digit (index 2) and 4th digit (index 4)
      if (i > 0 && (i == 2 || (includeDay && i == 4))) {
        formattedBuffer.write('/');
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

    // 3. UX: If the cursor lands exactly before a slash, push it after the slash
    if (newSelectionIndex < formattedText.length &&
        formattedText[newSelectionIndex] == '/') {
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
