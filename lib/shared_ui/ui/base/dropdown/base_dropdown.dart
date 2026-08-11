import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class BaseDropDown<T> extends StatelessWidget {
  const BaseDropDown({
    required this.onChanged,
    required this.items,
    required this.selectedItem,
    required this.label,
    this.hint,
    this.dropdownHeight = 45,
    this.validator,
    this.showLabelAtTopLeft = false,
    this.isSimple = false,
    this.adviceMessage,
    this.onClear,
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
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final centeredItems = items?.map((item) {
      return DropdownMenuItem<T>(
        key: item.key,
        value: item.value,
        onTap: item.onTap,
        enabled: item.enabled,
        alignment: Alignment.center,
        child: Center(child: item.child),
      );
    }).toList();

    final topLeftLabel =
        selectedItem != null &&
            showLabelAtTopLeft &&
            (label?.isNotEmpty ?? false)
        ? Positioned(
            left: Sizes.p4,
            child: BaseText.caption(
              label!,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          )
        : null;

    final bool canClear = selectedItem != null && onClear != null;

    void handleClear(FormFieldState<T> state) {
      state.didChange(null);
      onClear?.call();
    }

    if (PlatformUtil.isCupertino && !isSimple) {
      final double screenWidth = MediaQuery.sizeOf(context).width;
      final selectedMenuItem = centeredItems?.firstWhereOrNull(
        (item) => item.value == selectedItem,
      );
      return FormField<T>(
        key: key,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,
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
                      disabledColor: theme.disabledColor.withValues(
                        alpha: 100 / 255,
                      ),
                      padding: const EdgeInsets.only(left: 15),
                      color: theme.disabledColor.withValues(alpha: 50 / 255),
                      onPressed:
                          onChanged == null || (centeredItems?.length ?? 0) < 1
                          ? null
                          : () async {
                              FocusManager.instance.primaryFocus?.unfocus();
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
                                      builder: (sheetContext) =>
                                          CupertinoActionSheet(
                                            title: BaseText(
                                              'Selecionar'.hardcoded,
                                            ),
                                            actions: centeredItems!.map((item) {
                                              return CupertinoActionSheetAction(
                                                onPressed: () {
                                                  if (item.enabled) {
                                                    Navigator.of(
                                                      sheetContext,
                                                    ).pop(item.value);
                                                  }
                                                },
                                                child: item.child,
                                              );
                                            }).toList(),
                                            cancelButton:
                                                CupertinoActionSheetAction(
                                                  isDefaultAction: true,
                                                  onPressed: () => Navigator.of(
                                                    sheetContext,
                                                  ).pop(),
                                                  child: BaseText.headline(
                                                    'Cancelar'.hardcoded,
                                                    color: CupertinoColors
                                                        .destructiveRed,
                                                  ),
                                                ),
                                          ),
                                    );

                                if (selected != null && onChanged != null) {
                                  state.didChange(selected);
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
                                : Center(
                                    child:
                                        hint ??
                                        BaseText.bodyLarge(
                                          label ?? 'Selecionar'.hardcoded,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  ),
                          ),
                          if (canClear)
                            BaseIconButton(
                              platformIcon: const PlatformIcon(
                                materialIcon: Icons.clear,
                                cupertinoIcon:
                                    CupertinoIcons.clear_circled_solid,
                                color: Colors.red,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () => handleClear(state),
                            )
                          else if (screenWidth > 300)
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
                  child: BaseText(
                    state.errorText!,
                    color: CupertinoColors.systemRed,
                    textType: TextType.bodySmall,
                  ),
                ),
            ],
          );
        },
      );
    }

    final bool isDropdownEnabled =
        onChanged != null && (centeredItems?.length ?? 0) > 0;

    return FormField<T>(
      key: key,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      validator: validator,
      initialValue: selectedItem,
      builder: (state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: dropdownHeight,
              child: Material(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(Sizes.p8)),
                ),
                color: theme.disabledColor.withValues(alpha: 30 / 255),
                child: InkWell(
                  onTap: isDropdownEnabled ? () {} : null,
                  customBorder: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(Sizes.p8)),
                  ),
                  child: Stack(
                    children: [
                      ?topLeftLabel,
                      DropdownButtonFormField<T>(
                        autovalidateMode:
                            AutovalidateMode.onUserInteractionIfError,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          errorStyle: TextStyle(height: 0, fontSize: 0),
                        ),
                        padding: const EdgeInsets.only(left: Sizes.p8),
                        dropdownColor: theme.colorScheme.surface,
                        initialValue: selectedItem,
                        isExpanded: true,
                        alignment: Alignment.center,
                        iconSize: 17,
                        icon: canClear
                            ? BaseIconButton(
                                platformIcon: const PlatformIcon(
                                  materialIcon: Icons.clear,
                                  cupertinoIcon: CupertinoIcons.clear,
                                  color: Colors.red,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () => handleClear(state),
                              )
                            : null,
                        onTap: adviceMessage == null
                            ? null
                            : () {
                                showAlertDialog(
                                  context: context,
                                  title: 'Atenção!'.hardcoded,
                                  contentText: adviceMessage,
                                );
                              },
                        hint: hint ?? (label != null ? BaseText(label!) : null),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: theme.textTheme.titleMedium?.fontSize,
                          color: theme.colorScheme.onSurface,
                          height: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        items: centeredItems,
                        onChanged:
                            onChanged == null ||
                                (centeredItems?.length ?? 0) < 1
                            ? null
                            : (value) {
                                if (value != null) {
                                  state.didChange(value);
                                  onChanged?.call(value);
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 15),
                child: BaseText(
                  state.errorText!,
                  color: theme.colorScheme.error,
                  textType: TextType.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }
}
