import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/assets/widgets/asset_card.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/assets/widgets/create_asset_button.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/widgets/open_drawer_icon_button.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite/prerequisite_step.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite/prerequisite_type.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/prerequisites/prerequisite_guide_card.dart';

@RoutePage()
class AssetsPage extends HookWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      context.read<AssetsCubit>().loadAssets();
      return null;
    }, []);

    return BaseScaffold(
      isScrollable: false,
      onRefresh: context.read<AssetsCubit>().loadAssets,
      appBar: BaseAppBar(
        title: 'Equipamentos'.hardcoded,
        leading: const OpenDrawerIconButton(),
        actions: const [CreateAssetButton()],
      ),
      body: BaseStateView<AssetsCubit, AssetsState, List<AssetEntity>>(
        dataSelector: (state) => state.assets,
        onRetry: context.read<AssetsCubit>().loadAssets,
        builder: (context, assets) {
          final hasAssets = context.select<AssetsCubit, bool>(
            (c) => c.state.hasAssets,
          );

          if (!hasAssets && assets.isEmpty) {
            WorkType workType = WorkType.hybrid;
            bool hasLocations = false;
            bool hasCustomers = false;
            bool hasLocationCreate = true;

            try {
              final company = context.watch<CompanyCubit>().state.company;
              if (company != null) workType = company.workType;
            } catch (_) {}

            try {
              hasLocations = context.select<LocationsCubit, bool>(
                (c) => c.state.hasLocations,
              );
            } catch (_) {}

            try {
              hasCustomers = context.select<CustomersCubit, bool>(
                (c) => c.state.hasCustomers,
              );
            } catch (_) {}

            try {
              final userCubit = context.watch<UsersCubit>();
              hasLocationCreate = userCubit.hasPermission(
                const ActionPermission.resource(
                  resourceType: ResourceType.locations,
                  permissionAction: PermissionAction.create,
                ),
              );
            } catch (_) {}

            final bool needsLocation =
                workType.isInternalOnly && !hasLocations;
            final bool needsCustomer =
                workType.isServiceProviderOnly && !hasCustomers;

            if (needsLocation) {
              return PrerequisiteGuideCard(
                title: 'Pré-requisitos para equipamentos'.hardcoded,
                subtitle:
                    'Cadastre um local para poder vincular seus equipamentos:'
                        .hardcoded,
                steps: [
                  PrerequisiteStep(
                    type: PrerequisiteType.location,
                    title: 'Cadastrar local'.hardcoded,
                    description:
                        'Locais físicos onde os equipamentos estão instalados.'
                            .hardcoded,
                    actionLabel: 'Cadastrar Local'.hardcoded,
                    isCompleted: false,
                    canPerformAction: hasLocationCreate,
                  ),
                ],
              );
            }

            if (needsCustomer) {
              return PrerequisiteGuideCard(
                title: 'Pré-requisitos para equipamentos'.hardcoded,
                subtitle:
                    'Cadastre um cliente para poder vincular seus equipamentos:'
                        .hardcoded,
                steps: [
                  PrerequisiteStep(
                    type: PrerequisiteType.customer,
                    title: 'Cadastrar cliente'.hardcoded,
                    description:
                        'Clientes externos que possuem equipamentos sob atendimento.'
                            .hardcoded,
                    actionLabel: 'Cadastrar Cliente'.hardcoded,
                    isCompleted: false,
                  ),
                ],
              );
            }

            return Center(
              child: BaseText.error('Nenhum equipamento cadastrado'.hardcoded),
            );
          }

          if (assets.isEmpty) {
            return Center(
              child: BaseText.error('Nenhum equipamento encontrado'.hardcoded),
            );
          }

          assets.sort((a, b) => a.name.compareTo(b.name));
          return ResponsiveListFlow(
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              return AssetCard(asset: asset, allAssets: assets);
            },
          );
        },
      ),
    );
  }
}
