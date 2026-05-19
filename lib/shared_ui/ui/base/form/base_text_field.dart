import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
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
                    style: const TextStyle(
                      color: AppColors.base,
                      fontSize: Sizes.p16,
                    ),
                    focusNode: focusNode,
                    placeholder: hintText,
                    prefix: prefixIcon,
                    suffix: suffixIcon,
                    padding: const EdgeInsets.all(Sizes.p16),
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
                      borderRadius: const BorderRadius.all(
                        Radius.circular(Sizes.p8),
                      ),
                    ),
                  ),
                  if (fieldState.hasError)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.p16,
                        vertical: Sizes.p8,
                      ),
                      child: Text(
                        fieldState.errorText ?? '',
                        style: const TextStyle(
                          color: CupertinoColors.destructiveRed,
                          fontSize: Sizes.p12,
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
            style: const TextStyle(color: AppColors.base, fontSize: Sizes.p16),
            focusNode: focusNode,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(Sizes.p16),
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
          gapH8,
          child,
        ],
      );
    }

    return child;
  }
}
