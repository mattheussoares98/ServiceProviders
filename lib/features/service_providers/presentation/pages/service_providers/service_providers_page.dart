import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/pages/service_providers/widgets/edit_service_provider_company_button.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/pages/service_providers/widgets/service_providers_profiles_items.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/title_and_subtitle.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

part './widgets/service_providers_body.dart';

@RoutePage()
class ServiceProvidersPage extends StatelessWidget {
  const ServiceProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final companyId = context.select(
      (SessionCubit cubit) => cubit.state.user.companyId,
    );

    return BlocProvider(
      create: (context) =>
          GetIt.I<ServiceProvidersCubit>()..loadCompanies(companyId),
      child: _ServiceProvidersView(companyId: companyId),
    );
  }
}

class _ServiceProvidersView extends StatelessWidget {
  const _ServiceProvidersView({required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      isScrollable: false,
      onRefresh: () =>
          context.read<ServiceProvidersCubit>().loadCompanies(companyId),
      appBar: BaseAppBar(
        title: 'Prestadores de serviço'.hardcoded,
        actions: [
          BaseIconButton(
            permission: const ActionPermission.resource(
              resource: ResourceType.serviceProviders,
              action: PermissionAction.create,
            ),
            platformIcon: const PlatformIcon(
              materialIcon: Icons.add,
              cupertinoIcon: CupertinoIcons.add,
            ),
            onPressed: () => context
                .read<ServiceProvidersCubit>()
                .navigateToCreateUpdateServiceProviderCompany(null),
          ),
        ],
      ),
      body: const _ServiceProvidersBody(),
    );
  }
}
