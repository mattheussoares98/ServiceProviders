part of '../create_provider_work_order_page.dart';

class _ProviderCompanyDropdown extends StatelessWidget {
  const _ProviderCompanyDropdown({
    required this.companies,
    required this.selected,
    required this.onChanged,
  });

  final List<ServiceProviderCompanyEntity> companies;
  final ServiceProviderCompanyEntity? selected;
  final ValueChanged<ServiceProviderCompanyEntity> onChanged;

  @override
  Widget build(BuildContext context) {
    if (companies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
        child: BaseText(
          'Nenhuma empresa contratante vinculada.'.hardcoded,
          color: Theme.of(context).colorScheme.error,
        ),
      );
    }
    // Nothing to choose when the user serves a single client.
    if (companies.length == 1) return const SizedBox.shrink();

    return BaseDropDown<ServiceProviderCompanyEntity>(
      key: const ValueKey('ProviderCompany'),
      showLabelAtTopLeft: true,
      label: 'Empresa contratante *'.hardcoded,
      selectedItem: selected,
      validator: (value) =>
          value == null ? 'Selecione a empresa'.hardcoded : null,
      items: companies
          .map(
            (company) =>
                DropdownMenuItem(value: company, child: BaseText(company.name)),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
