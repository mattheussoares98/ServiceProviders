import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/pages/service_providers/widgets/edit_service_provider_company_button.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/pages/service_providers/widgets/service_provider_company_subtitle.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/pages/service_providers/widgets/service_providers_invitations_items.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

part './widgets/service_providers_body.dart';

@RoutePage()
class ServiceProvidersPage extends HookWidget {
  const ServiceProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    observeLoading([
      ObservedLoadingTarget(
        context.read<ServiceProvidersCubit>(),
        sections: const {
          ServiceProvidersSections.saveCompany: {SectionStatus.running},
          ServiceProvidersSections.saveProfile: {SectionStatus.running},
          ServiceProvidersSections.sendInvitation: {SectionStatus.running},
          ServiceProvidersSections.deleteInvitation: {SectionStatus.running},
        },
      ),
    ]);
    return BaseScaffold(
      isScrollable: false,
      onRefresh: () => context
          .read<ServiceProvidersCubit>()
          .loadCompaniesAndProfiles(forceRefresh: true),
      appBar: BaseAppBar(
        title: 'Prestadores de serviço'.hardcoded,
        actions: [
          BaseIconButton(
            permission: const ActionPermission.resource(
              resourceType: ResourceType.serviceProviders,
              permissionAction: PermissionAction.create,
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
