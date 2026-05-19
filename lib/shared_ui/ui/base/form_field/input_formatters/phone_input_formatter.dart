import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Get the clean text (digits only)
    final newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Don't allow more than 9 digits (for XXXXX-XXXX)
    if (newText.length > 9) {
      return oldValue;
    }

    var formattedText = newText;
    int selectionIndex = newValue.selection.end;

    // Determine where to put the hyphen based on the length
    if (newText.length > 4) {
      // Handle 8-digit numbers (XXXX-XXXX)
      if (newText.length <= 8) {
        formattedText = '${newText.substring(0, 4)}-${newText.substring(4)}';
        // Adjust cursor position if it's after the hyphen
        if (selectionIndex > 4) {
          selectionIndex++;
        }
      }
      // Handle 9-digit numbers (XXXXX-XXXX)
      else if (newText.length == 9) {
        formattedText = '${newText.substring(0, 5)}-${newText.substring(5)}';
        if (selectionIndex > 5) {
          selectionIndex++;
        }
      }
    }

    // Ensure the cursor position is not out of bounds
    if (selectionIndex > formattedText.length) {
      selectionIndex = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
