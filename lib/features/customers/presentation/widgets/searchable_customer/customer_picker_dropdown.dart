import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/widgets/searchable_customer/searchable_customer_picker_modal.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class CustomerPickerDropdown extends StatelessWidget {
  const CustomerPickerDropdown({
    super.key,
    this.containerKey,
    this.clearButtonKey,
    required this.selectedCustomerId,
    required this.onChanged,
    this.isRequired = false,
  });

  final Key? containerKey;
  final Key? clearButtonKey;
  final String? selectedCustomerId;
  final ValueChanged<String?>? onChanged;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final allCustomers = context.select(
      (CustomersCubit cubit) => cubit.state.customers,
    );
    final activeCustomers = allCustomers
        .where((c) => c.isActive || c.id == selectedCustomerId)
        .toList();

    final selectedCustomer = allCustomers.firstWhereOrNull(
      (c) => c.id == selectedCustomerId,
    );

    final hasSelection = selectedCustomer != null;
    final canInteract = onChanged != null && activeCustomers.isNotEmpty;

    final hintText = activeCustomers.isEmpty
        ? 'Sem clientes cadastrados'.hardcoded
        : 'Selecione o cliente'.hardcoded;

    final label = isRequired ? 'Cliente *'.hardcoded : 'Cliente'.hardcoded;

    return FormField<String>(
      initialValue: selectedCustomerId,
      validator: isRequired
          ? (val) => selectedCustomerId == null
                ? 'Selecione um cliente'.hardcoded
                : null
          : null,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: containerKey ?? const ValueKey('Customer'),
              height: 48,
              decoration: BoxDecoration(
                color: context.theme.disabledColor.withValues(alpha: 50 / 255),
                borderRadius: BorderRadius.circular(Sizes.p8),
                border: fieldState.hasError
                    ? Border.all(color: CupertinoColors.systemRed)
                    : null,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(Sizes.p8),
                onTap: canInteract
                    ? () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        final result = await SearchableCustomerPickerModal.show(
                          context,
                          customers: activeCustomers,
                          selectedCustomerId: selectedCustomerId,
                        );
                        if (result != null && onChanged != null) {
                          if (result.isClear) {
                            fieldState.didChange(null);
                            onChanged!(null);
                          } else if (result.customer != null) {
                            fieldState.didChange(result.customer!.id);
                            onChanged!(result.customer!.id);
                          }
                        }
                      }
                    : null,
                child: Stack(
                  children: [
                    if (hasSelection)
                      Positioned(
                        left: Sizes.p8,
                        top: Sizes.p4,
                        child: BaseText.caption(label, color: AppColors.fade),
                      ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: Sizes.p12,
                          right: Sizes.p40,
                          top: hasSelection ? Sizes.p12 : 0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: BaseText(
                            hasSelection ? selectedCustomer.name : hintText,
                            color: hasSelection ? null : AppColors.fade,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: Sizes.p8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: hasSelection && onChanged != null && !isRequired
                            ? BaseIconButton(
                                key:
                                    clearButtonKey ??
                                    const ValueKey('CustomerClearButton'),
                                platformIcon: const PlatformIcon(
                                  materialIcon: Icons.clear,
                                  cupertinoIcon:
                                      CupertinoIcons.clear_circled_solid,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  fieldState.didChange(null);
                                  onChanged!(null);
                                },
                              )
                            : const PlatformIcon(
                                materialIcon: Icons.search,
                                cupertinoIcon: CupertinoIcons.search,
                                color: AppColors.fade,
                                size: 18,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (fieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: Sizes.p4, left: Sizes.p8),
                child: BaseText(
                  fieldState.errorText!,
                  color: CupertinoColors.systemRed,
                ),
              ),
          ],
        );
      },
    );
  }
}
