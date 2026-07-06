import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

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
    final colorScheme = context.colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Sizes.p12),
      borderSide: BorderSide(color: colorScheme.onSurface.withAlpha(75)),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Sizes.p12),
      borderSide: BorderSide(color: colorScheme.primary),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Sizes.p12),
      borderSide: BorderSide(color: colorScheme.error),
    );

    final disabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Sizes.p12),
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
        top: isMultiLine ?? false ? Sizes.p8 : 0,
        bottom: isMultiLine ?? false ? Sizes.p8 : 0,
        left: Sizes.p8,
      ),
      filled: true,
      fillColor: fillColor,
      alignLabelWithHint: isMultiLine,
    );
  }
}
