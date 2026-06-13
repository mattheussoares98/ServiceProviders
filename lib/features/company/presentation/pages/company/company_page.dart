import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:clean_architecture/features/company/presentation/pages/company/widgets/company_detail_card.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/session/session_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class CompanyPage extends StatelessWidget {
  const CompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<CompanyCubit>()..loadCompany(),
      child: Builder(
        builder: (context) {
          return BaseScaffold(
            observeScreenChanges: true,
            onRefresh: () =>
                context.read<CompanyCubit>().loadCompany(forceRefresh: true),
            appBar: BaseAppBar(
              title: 'Empresa'.hardcoded,
              actions: [
                BlocSelector<SessionCubit, SessionState, bool>(
                  selector: (state) => state.user.isAdmin,
                  builder: (context, isAdmin) {
                    if (!isAdmin) return const SizedBox.shrink();
                    return BaseIconButton(
                      platformIcon: const PlatformIcon(
                        materialIcon: Icons.add,
                        cupertinoIcon: CupertinoIcons.add,
                      ),
                      onPressed: context
                          .read<CompanyCubit>()
                          .navigateToCreateCompany,
                    );
                  },
                ),
              ],
            ),
            body: const _CompanyBody(),
          );
        },
      ),
    );
  }
}

class _CompanyBody extends StatelessWidget {
  const _CompanyBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.p8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<CompanyCubit, CompanyState>(
            builder: (context, state) {
              switch (state.status) {
                case StateStatus.loading:
                  return const Center(child: LoadingCircle());
                case StateStatus.error:
                  return Center(
                    child: BaseText.bodyLarge(
                      'Erro ao carregar dados da empresa'.hardcoded,
                      color: context.colorScheme.error,
                    ),
                  );
                case StateStatus.loaded:
                default:
                  final company = state.company;
                  if (company == null) {
                    return Center(
                      child: BaseText.bodyLarge(
                        'Nenhuma empresa foi encontrada'.hardcoded,
                        color: context.colorScheme.error,
                      ),
                    );
                  }
                  return CompanyDetailCard(company: company);
              }
            },
          ),
        ],
      ),
    );
  }
}
