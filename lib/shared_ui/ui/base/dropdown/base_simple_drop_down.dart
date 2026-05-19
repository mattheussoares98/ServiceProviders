import 'package:clean_architecture/shared_ui/ui/base/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseSimpleDropDown<T> extends StatelessWidget {
  const BaseSimpleDropDown({
    super.key,
    required this.onChanged,
    required this.items,
    required this.value,
    required this.hint,
    this.validator,
    this.isLoading,
    this.autovalidateMode,
    this.onTap,
    this.padding,
    this.iconSize,
  });
  final void Function(T?)? onChanged;
  final List<DropdownMenuItem<T>>? items;
  final T value;
  final String hint;
  final String? Function(T?)? validator;
  final bool? isLoading;
  final AutovalidateMode? autovalidateMode;
  final void Function(T?)? onTap;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onChanged == null ? null : () {},
        child: DropdownButtonFormField<T>(
          onTap: onTap == null ? null : () => onTap!(value),
          decoration: const InputDecoration(
            border: InputBorder.none,
            errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none),
          ),
          initialValue: value,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: Sizes.p16),
          items: items,
          alignment: Alignment.center,
          isExpanded: true,
          onChanged: onChanged,
          autovalidateMode: autovalidateMode,
          dropdownColor: Colors.white,
          validator: validator,
          iconSize: iconSize ?? 24,
          icon: Padding(
            padding: const EdgeInsets.only(right: Sizes.p8),
            child: SizedBox(
              child: isLoading ?? false
                  ? const LoadingCircle()
                  : const PlatformIcon(
                      cupertinoIcon: CupertinoIcons.chevron_down,
                      materialIcon: Icons.arrow_drop_down,
                    ),
            ),
          ),
          hint: Center(
            child: Text(
              hint,
              style: onChanged == null
                  ? TextStyle(color: context.theme.disabledColor)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
