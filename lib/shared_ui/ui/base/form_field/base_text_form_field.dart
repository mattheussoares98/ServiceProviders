import 'package:clean_architecture/core/utils/platform_util.dart';
import 'package:clean_architecture/shared_ui/cubits/keyboard_visibility/keyboard_visibility_cubit.dart';
import 'package:clean_architecture/shared_ui/themes/app_decorations.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/overlay_manager.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cupertino_form_field.dart';

class BaseTextFormField extends StatelessWidget {
  const BaseTextFormField({
    super.key,
    this.maxLength = 50,
    this.controller,
    this.enabled = true,
    this.onFieldSubmitted,
    this.validator,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.autovalidateMode,
    this.focusNode,
    this.keyboardType,
    this.onChanged,
    this.inputFormatters,
    this.onTap,
    this.maxLines,
    this.textInputAction,
    this.onEditingComplete,
    this.obscureText = false,
    this.autofocus = false,
  });
  final bool? enabled;
  final TextEditingController? controller;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final bool obscureText;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final int? maxLength;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final int? maxLines;
  final bool? autofocus;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtil.isCupertino) {
      return CupertinoFormField(baseTextFormField: this, key: key);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: TextFormField(
        key: key,
        scrollPadding: const EdgeInsets.only(bottom: 80),
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
        minLines: 1,
        maxLines: maxLines ?? 1,
        enabled: enabled,
        controller: controller,
        autovalidateMode: autovalidateMode,
        onFieldSubmitted: onFieldSubmitted,
        inputFormatters: inputFormatters,
        validator: validator,
        obscureText: obscureText,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLength: maxLength,
        onChanged: onChanged,
        onTap: onTap,
        autofocus: autofocus ?? false,
        buildCounter:
            (
              context, {
              required currentLength,
              required isFocused,
              required maxLength,
            }) => null,
        decoration: AppDecorations.input(
          enabled: enabled ?? true,
          context: context,
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          errorText: errorText,
          isMultiLine: (maxLines ?? 1) > 1,
        ),
      ),
    );
  }
}
