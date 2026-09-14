import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/company_body.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_running.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

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
          CompanySections.updateGovernanceParameters,
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
      body: const CompanyBody(),
    );
  }
}
