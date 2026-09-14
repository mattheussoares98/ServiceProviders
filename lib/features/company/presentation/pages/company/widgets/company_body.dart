import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/company_detail_card.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/company_switcher_section.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/escalation_parameters_card/escalation_parameters_card.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/work_order_governance_parameters_card.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class CompanyBody extends StatelessWidget {
  const CompanyBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        final loadSection = state.section(BaseSections.load);
        if (loadSection.isRunning) {
          return const Center(child: LoadingCircle());
        }
        if (loadSection.isError) {
          return Center(
            child: BaseText.bodyLarge(
              loadSection.errorMessage?.isNotEmpty == true
                  ? loadSection.errorMessage!
                  : 'Erro ao carregar dados da empresa'.hardcoded,
              color: context.colorScheme.error,
            ),
          );
        }
        final company = state.company;
        if (company == null) {
          return Center(
            child: BaseText.bodyLarge(
              'Nenhuma empresa foi encontrada'.hardcoded,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CompanyDetailCard(company: company),
            BlocSelector<SessionCubit, SessionState, bool>(
              selector: (s) => s.user.isSuperAdmin,
              builder: (context, isSuperAdmin) {
                if (!isSuperAdmin || state.companies.length <= 1) {
                  return const SizedBox.shrink();
                }
                return CompanySwitcherSection(
                  companies: state.companies,
                  selectedCompanyId: state.selectedCompanyId ?? company.id,
                );
              },
            ),
            if (state.parameters != null) ...[
              WorkOrderGovernanceParametersCard(parameters: state.parameters!),
              EscalationParametersCard(
                parameters: state.parameters!,
                permissionGroups: state.permissionGroups,
              ),
            ],
          ],
        );
      },
    );
  }
}
