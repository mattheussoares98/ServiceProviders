import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/company_detail_card.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/company_switcher_section.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/escalation_parameters_card/escalation_parameters_card.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_running.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

@RoutePage()
class CompanyPage extends HookWidget {
  const CompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    observeRunning([
      ObservedLoadingTarget(
        context.read<CompanyCubit>(),
        sections: const {
          CompanySections.switchCompany,
          CompanySections.updateEscalationParameters,
          CompanySections.changeLogo,
        },
      ),
    ]);

    return BaseScaffold(
      onRefresh: () =>
          context.read<CompanyCubit>().loadCompany(forceRefresh: true),
      appBar: BaseAppBar(
        title: 'Empresa'.hardcoded,
        actions: [
          BlocSelector<SessionCubit, SessionState, bool>(
            selector: (state) => state.user.isSuperAdmin,
            builder: (context, isSuperAdmin) {
              if (!isSuperAdmin) return const SizedBox.shrink();
              return BaseIconButton(
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.add,
                  cupertinoIcon: CupertinoIcons.add,
                ),
                onPressed: context.read<CompanyCubit>().navigateToCreateCompany,
              );
            },
          ),
        ],
      ),
      body: const _CompanyBody(),
    );
  }
}

class _CompanyBody extends StatelessWidget {
  const _CompanyBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        switch (state.status) {
          case DataStatus.loading:
            return const Center(child: LoadingCircle());
          case DataStatus.loadingError:
            return Center(
              child: BaseText.bodyLarge(
                'Erro ao carregar dados da empresa'.hardcoded,
                color: context.colorScheme.error,
              ),
            );
          case DataStatus.loaded:
          default:
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
                if (state.parameters != null)
                  EscalationParametersCard(
                    parameters: state.parameters!,
                    permissionGroups: state.permissionGroups,
                  ),
              ],
            );
        }
      },
    );
  }
}
