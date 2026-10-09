import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

part 'customer_picker_result.dart';
part 'customer_tile.dart';

class SearchableCustomerPickerModal extends HookWidget {
  const SearchableCustomerPickerModal({
    super.key,
    required this.customers,
    this.selectedCustomerId,
    this.onSelected,
  });

  final List<CustomerEntity> customers;
  final String? selectedCustomerId;
  final ValueChanged<CustomerEntity?>? onSelected;

  static Future<CustomerPickerResult?> show(
    BuildContext context, {
    required List<CustomerEntity> customers,
    String? selectedCustomerId,
    ValueChanged<CustomerEntity?>? onSelected,
  }) async {
    return await showModalPage<CustomerPickerResult>(
      SearchableCustomerPickerModal(
        customers: customers,
        selectedCustomerId: selectedCustomerId,
        onSelected: onSelected,
      ),
      context,
    );
  }

  bool _matchesQuery(CustomerEntity customer, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase().trim();
    final nameMatch = customer.name.toLowerCase().contains(q);
    final docMatch = customer.document?.toLowerCase().contains(q) ?? false;
    final contactMatch =
        customer.contactName?.toLowerCase().contains(q) ?? false;
    final emailMatch =
        customer.contactEmail?.toLowerCase().contains(q) ?? false;
    final phoneMatch =
        customer.contactPhone?.toLowerCase().contains(q) ?? false;
    final cityMatch = customer.city?.toLowerCase().contains(q) ?? false;
    return nameMatch ||
        docMatch ||
        contactMatch ||
        emailMatch ||
        phoneMatch ||
        cityMatch;
  }

  void _selectCustomer(BuildContext context, CustomerEntity customer) {
    onSelected?.call(customer);
    Navigator.of(context).pop(CustomerPickerResult.selected(customer));
  }

  void _clearSelection(BuildContext context) {
    onSelected?.call(null);
    Navigator.of(context).pop(const CustomerPickerResult.cleared());
  }

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final query = searchQuery.value.trim();

    final filteredCustomers = useMemoized(() {
      return customers.where((c) => _matchesQuery(c, query)).toList();
    }, [customers, query]);

    return Padding(
      padding: EdgeInsets.only(
        left: Sizes.p16,
        right: Sizes.p16,
        top: Sizes.p16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Sizes.p16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: BaseText.headline('Selecionar cliente'.hardcoded),
              ),
              BaseButton.text(
                key: const ValueKey('SearchableCustomerPickerClearButton'),
                onPressed: selectedCustomerId != null
                    ? () => _clearSelection(context)
                    : null,
                text: 'Limpar'.hardcoded,
              ),
            ],
          ),
          gapH12,
          BaseTextFormField(
            key: const ValueKey('SearchableCustomerPickerSearchField'),
            controller: searchController,
            hintText: 'Buscar por nome, documento, contato...'.hardcoded,
            prefixIcon: const PlatformIcon(
              materialIcon: Icons.search,
              cupertinoIcon: CupertinoIcons.search,
            ),
            suffixIcon: query.isNotEmpty
                ? BaseIconButton(
                    onPressed: searchController.clear,
                    platformIcon: const PlatformIcon(
                      materialIcon: Icons.clear,
                      cupertinoIcon: CupertinoIcons.clear_circled,
                    ),
                  )
                : null,
          ),
          gapH8,
          if (filteredCustomers.isEmpty)
            Expanded(
              child: Center(
                key: const ValueKey('SearchableCustomerPickerEmptyState'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PlatformIcon(
                      materialIcon: Icons.search_off,
                      cupertinoIcon: CupertinoIcons.search,
                      color: AppColors.fade,
                    ),
                    gapH12,
                    BaseText(
                      customers.isEmpty
                          ? 'Nenhum cliente cadastrado'.hardcoded
                          : 'Nenhum cliente encontrado'.hardcoded,
                      color: AppColors.fade,
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = filteredCustomers[index];
                  return _CustomerTile(
                    customer: customer,
                    isSelected: customer.id == selectedCustomerId,
                    onTap: () => _selectCustomer(context, customer),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
