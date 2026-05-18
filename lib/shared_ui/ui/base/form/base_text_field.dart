import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:clean_architecture/shared_ui/utils/ui_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseTextField extends StatelessWidget {
  const BaseTextField({
    super.key,
    this.title,
    this.titleColor,
    this.titleSize,
    this.titleFontWeight,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.obscureText = false,
    this.focusNode,
    this.hintText = '',
    this.prefixIcon,
    this.suffixIcon,
  });
  final String? title;
  final Color? titleColor;
  final TextType? titleSize;
  final FontWeight? titleFontWeight;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool readOnly;
  final String? initialValue;
  final void Function(String?)? onChanged;
  final bool obscureText;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    Widget child = context.isCupertino
        ? FormField<String>(
            initialValue: initialValue,
            validator: validator,
            autovalidateMode: autovalidateMode,
            builder: (fieldState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoTextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    onChanged: (value) {
                      fieldState.didChange(value);
                      onChanged?.call(value);
                    },
                    readOnly: readOnly,
                    obscureText: obscureText,
                    obscuringCharacter: '*',
                    style: TextStyle(
                      color: AppColors.base,
                      fontSize: Space.sMedium.value,
                    ),
                    focusNode: focusNode,
                    placeholder: hintText,
                    prefix: prefixIcon,
                    suffix: suffixIcon,
                    padding: UIHelpers.paddingA16,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: fieldState.hasError
                            ? CupertinoColors.destructiveRed
                            : const CupertinoDynamicColor.withBrightness(
                                color: Color(0x33000000),
                                darkColor: Color(0x33FFFFFF),
                              ),
                        width: 0,
                      ),
                      borderRadius: UIHelpers.radiusC8,
                    ),
                  ),
                  if (fieldState.hasError)
                    Padding(
                      padding: UIHelpers.paddingH16V8,
                      child: Text(
                        fieldState.errorText ?? '',
                        style: TextStyle(
                          color: CupertinoColors.destructiveRed,
                          fontSize: Space.small.value,
                        ),
                      ),
                    ),
                ],
              );
            },
          )
        : TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            initialValue: initialValue,
            onChanged: onChanged,
            validator: validator,
            readOnly: readOnly,
            autovalidateMode: autovalidateMode,
            obscureText: obscureText,
            obscuringCharacter: '*',
            style: TextStyle(
              color: AppColors.base,
              fontSize: Space.sMedium.value,
            ),
            focusNode: focusNode,
            decoration: InputDecoration(
              contentPadding: UIHelpers.paddingA16,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              hintText: hintText,
            ),
          );

    if (title != null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BaseText(
            title!,
            color: titleColor,
            textType: titleSize ?? TextType.titleSmall,
          ),
          UIHelpers.spaceV8,
          child,
        ],
      );
    }

    return child;
  }
}
