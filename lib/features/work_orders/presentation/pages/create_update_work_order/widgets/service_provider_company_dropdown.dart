import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class ServiceProviderCompanyDropdown extends StatelessWidget {
  const ServiceProviderCompanyDropdown({
    super.key,
    required this.onChanged,
    required this.selectedCompanyId,
  });

  final String? selectedCompanyId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final companies = context.select<ServiceProvidersCubit, List<ServiceProviderCompanyEntity>>(
      (cubit) => cubit.state.companies,
    );

    final dropdownItems = companies
        .map(
          (company) => DropdownMenuItem(
            value: company.id,
            child: BaseText(company.name),
          ),
        )
        .toList();

    return BaseDropDown<String?>(
      key: const ValueKey('ServiceProviderCompany'),
      label: 'Prestador de Serviços (empresa)'.hardcoded,
      showLabelAtTopLeft: true,
      selectedItem: selectedCompanyId,
      items: dropdownItems,
      onChanged: onChanged,
    );
  }
}
