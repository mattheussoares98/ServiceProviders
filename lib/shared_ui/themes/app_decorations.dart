import 'package:flutter/material.dart';

class AppDecorations {
  static InputDecoration input({
    required BuildContext context,
    bool enabled = true,
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    bool? isMultiLine,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), //TODO fix this size
      borderSide: BorderSide(color: colorScheme.onSurface.withAlpha(75)),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), //TODO fix this size
      borderSide: BorderSide(color: colorScheme.primary),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), //TODO fix this size
      borderSide: BorderSide(color: colorScheme.error),
    );

    final disabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), //TODO fix this size
      borderSide: BorderSide(color: colorScheme.onSurface.withAlpha(50)),
    );

    final fillColor = enabled
        ? colorScheme.surfaceContainerHighest.withAlpha(125)
        : colorScheme.onSurface.withAlpha(25);

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(
        color: enabled
            ? colorScheme.onSurface.withAlpha(200)
            : colorScheme.onSurface.withAlpha(100),
        fontSize: 12,
      ),
      hintStyle: TextStyle(
        color: enabled
            ? colorScheme.onSurface.withAlpha(125)
            : colorScheme.onSurface.withAlpha(100),
        fontSize: 12,
      ),
      enabled: enabled,
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      disabledBorder: disabledBorder,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.only(
        top: isMultiLine ?? false ? 8 /* TODO fix this value */ : 0,
        bottom: isMultiLine ?? false ? 8 /* TODO fix this value */ : 0,
        left: 8 /* TODO fix this value */,
      ),
      filled: true,
      fillColor: fillColor,
      alignLabelWithHint: isMultiLine,
    );
  }
}
