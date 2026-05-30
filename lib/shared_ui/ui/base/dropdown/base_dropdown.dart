import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/core/utils/platform_util.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DefaultDropDown<T> extends StatelessWidget {
  const DefaultDropDown({
    required this.onChanged,
    required this.items,
    required this.selectedItem,
    required this.label,
    this.hint,
    this.dropdownHeight = 40,
    this.validator,
    this.showLabelAtTopLeft = false,
    this.isSimple = false,
    this.adviceMessage,
    super.key,
  });
  final void Function(T)? onChanged;
  final List<DropdownMenuItem<T>>? items;
  final Widget? hint;
  final T? selectedItem;
  final String? label;
  final double? dropdownHeight;
  final String? Function(T?)? validator;
  final bool showLabelAtTopLeft;
  final bool isSimple;
  final String? adviceMessage;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final topLeftLabel =
        selectedItem != null &&
            showLabelAtTopLeft &&
            (label?.isNotEmpty ?? false)
        ? Positioned(
            left: Sizes.p4,
            child: Text(
              label!,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10),
            ),
          )
        : null;

    if (PlatformUtil.isCupertino && !isSimple) {
      final double screenWidth = MediaQuery.sizeOf(context).width;
      final selectedMenuItem = items?.firstWhereOrNull(
        (item) => item.value == selectedItem,
      );
      return FormField(
        validator: validator,
        initialValue: selectedItem,
        builder: (state) {
          return Column(
            children: [
              SizedBox(
                height: dropdownHeight,
                child: Stack(
                  children: [
                    ?topLeftLabel,
                    CupertinoButton(
                      disabledColor: theme.disabledColor.withAlpha(100),
                      padding: const EdgeInsets.only(left: 15),
                      color: theme.disabledColor.withAlpha(50),
                      onPressed: onChanged == null || (items?.length ?? 0) < 1
                          ? null
                          : () async {
                              if (adviceMessage != null) {
                                final ok = await showAlertDialog(
                                  context: context,
                                  title: 'Atenção!'.hardcoded,
                                  contentText: adviceMessage,
                                  defaultActionText: 'Continuar'.hardcoded,
                                  cancelActionText: 'Cancelar'.hardcoded,
                                );
                                if (ok != true) return;
                              }
                              if (context.mounted) {
                                final selected =
                                    await showCupertinoModalPopup<T>(
                                      context: context,
                                      builder: (_) => CupertinoActionSheet(
                                        title: Text('Selecionar'.hardcoded),
                                        actions: items!.map((item) {
                                          return CupertinoActionSheetAction(
                                            onPressed: () {
                                              if (item.enabled) {
                                                Navigator.of(
                                                  context,
                                                ).pop(item.value);
                                              }
                                            },
                                            child: item.child,
                                          );
                                        }).toList(),
                                        cancelButton:
                                            CupertinoActionSheetAction(
                                              isDefaultAction: true,
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text(
                                                'Cancelar'.hardcoded,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: CupertinoColors
                                                          .destructiveRed,
                                                    ),
                                              ),
                                            ),
                                      ),
                                    );

                                if (selected != null && onChanged != null) {
                                  onChanged!(selected);
                                }
                              }
                            },
                      child: Row(
                        children: [
                          Expanded(
                            child: selectedMenuItem != null
                                ? DefaultTextStyle(
                                    style:
                                        theme.textTheme.bodyLarge ??
                                        const TextStyle(),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    child: selectedMenuItem.child,
                                  )
                                : Text(
                                    label ?? 'Selecionar'.hardcoded,
                                    maxLines: 1,
                                    style: theme.textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                          if (screenWidth > 300)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Sizes.p16,
                              ),
                              child: Icon(CupertinoIcons.chevron_down),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 15),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    final bool isDropdownEnabled =
        onChanged != null && (items?.length ?? 0) > 0;

    return SizedBox(
      height: dropdownHeight,
      child: Material(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Sizes.p8)),
        ),
        color: theme.disabledColor.withAlpha(30),
        child: InkWell(
          onTap: isDropdownEnabled ? () {} : null,
          customBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(Sizes.p8)),
          ),
          child: Stack(
            children: [
              ?topLeftLabel,
              DropdownButtonFormField<T>(
                autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                decoration: const InputDecoration(border: InputBorder.none),
                padding: const EdgeInsets.only(left: Sizes.p8),
                dropdownColor: Colors.white,
                validator: validator,
                initialValue: selectedItem,
                isExpanded: true,
                alignment: Alignment.center,
                iconSize: 17,
                onTap: adviceMessage == null
                    ? null
                    : () {
                        showAlertDialog(
                          context: context,
                          title: 'Atenção!'.hardcoded,
                          contentText: adviceMessage,
                        );
                      },
                hint: hint ?? (label != null ? Text(label!) : null),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: theme.textTheme.titleMedium?.fontSize,
                  color: Colors.black,
                  height: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                items: items,
                onChanged: onChanged == null || (items?.length ?? 0) < 1
                    ? null
                    : (value) {
                        if (value != null && onChanged != null) {
                          onChanged!(value);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
