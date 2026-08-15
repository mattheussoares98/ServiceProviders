part of '../create_update_work_order_page.dart';

class _ServiceProviderCompanyDropdown extends StatelessWidget {
  const _ServiceProviderCompanyDropdown({
    required this.onChanged,
    required this.selectedCompanyId,
  });

  final String? selectedCompanyId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final companies = context
        .select<ServiceProvidersCubit, List<ServiceProviderCompanyEntity>>(
          (cubit) => cubit.state.companies,
        );

    if (companies.isEmpty) {
      return const SizedBox.shrink();
    }

    final dropdownItems = companies
        .map(
          (company) => DropdownMenuItem(
            value: company.id,
            child: BaseText(company.name),
          ),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.only(top: Sizes.p8),
      child: BaseDropDown<String?>(
        key: const ValueKey('ServiceProviderCompany'),
        label: 'Empresa prestadora do serviço'.hardcoded,
        showLabelAtTopLeft: true,
        selectedItem: selectedCompanyId,
        items: dropdownItems,
        onChanged: onChanged,
      ),
    );
  }
}
