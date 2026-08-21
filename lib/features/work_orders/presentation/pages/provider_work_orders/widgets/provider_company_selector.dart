import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/chip/base_choice_chip.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

/// Lets a provider narrow the list to one of the provider companies they belong
/// to. Hidden when they belong to a single company, since there is nothing to
/// choose. An empty selection means every company.
class ProviderCompanySelector extends StatelessWidget {
  const ProviderCompanySelector({super.key});

  static const _allCompaniesId = '';

  @override
  Widget build(BuildContext context) {
    final companies = context
        .select<WorkOrdersCubit, List<ServiceProviderCompanyEntity>>(
          (cubit) => cubit.state.providerCompanies,
        );

    if (companies.length < 2) return const SizedBox.shrink();

    final selectedId = context.select<WorkOrdersCubit, String?>(
      (cubit) => cubit.state.selectedProviderCompanyId,
    );

    final names = {
      for (final company in companies) company.id: company.name,
      _allCompaniesId: 'Todas as empresas'.hardcoded,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.p8,
        vertical: Sizes.p4,
      ),
      child: BaseChoiceChip<String>(
        items: [_allCompaniesId, ...companies.map((company) => company.id)],
        selections: [selectedId ?? _allCompaniesId],
        itemLabelBuilder: (id) => names[id] ?? '',
        onChanged: (id) => context.read<WorkOrdersCubit>().selectProviderCompany(
          id == _allCompaniesId ? null : id,
        ),
      ),
    );
  }
}
