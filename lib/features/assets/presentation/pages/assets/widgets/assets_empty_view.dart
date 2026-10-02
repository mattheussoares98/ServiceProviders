import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_empty_state.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class AssetsEmptyView extends StatelessWidget {
  const AssetsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final workType = context.select<CompanyCubit, WorkType>(
      (c) => c.state.company?.workType ?? WorkType.hybrid,
    );
    final hasLocations = context.select<LocationsCubit, bool>(
      (c) => c.state.hasLocations,
    );
    final hasCustomers = context.select<CustomersCubit, bool>(
      (c) => c.state.hasCustomers,
    );
    final hasLocationCreate = context.select<UsersCubit, bool>(
      (c) => c.hasPermission(
        const ActionPermission.resource(
          resourceType: ResourceType.locations,
          permissionAction: PermissionAction.create,
        ),
      ),
    );

    final bool needsLocation = workType.requiresLocation && !hasLocations;
    final bool needsCustomer = workType.requiresCustomer && !hasCustomers;

    if (needsLocation) {
      return BaseEmptyState(
        title: 'Cadastrar local'.hardcoded,
        description:
            'Cadastre um local para poder vincular seus equipamentos'.hardcoded,
        actionLabel: 'Cadastrar Local'.hardcoded,
        canPerformAction: hasLocationCreate,
        onAction: () =>
            context.read<LocationsCubit>().navigateToCreateUpdateLocation(),
        icon: const PlatformIcon(
          materialIcon: Icons.location_on_rounded,
          cupertinoIcon: CupertinoIcons.location_solid,
        ),
      );
    }

    if (needsCustomer) {
      return BaseEmptyState(
        title: 'Cadastrar cliente'.hardcoded,
        description: 'Cadastre um cliente para poder vincular seus equipamentos'
            .hardcoded,
        actionLabel: 'Cadastrar Cliente'.hardcoded,
        onAction: () =>
            context.read<CustomersCubit>().navigateToCreateUpdateCustomer(),
        icon: const PlatformIcon(
          materialIcon: Icons.person_add_alt_1_rounded,
          cupertinoIcon: CupertinoIcons.person_badge_plus,
        ),
      );
    }

    return BaseEmptyState(
      title: 'Cadastrar equipamento'.hardcoded,
      description:
          'Cadastre equipamentos para poder vincular a ${needsCustomer ? 'locais' : 'clientes'}'
              .hardcoded,
      actionLabel: 'Cadastrar Equipamento'.hardcoded,
      onAction: () => context.read<AssetsCubit>().navigateToCreateUpdateAsset(),
      icon: const PlatformIcon(
        materialIcon: Icons.build_outlined,
        cupertinoIcon: CupertinoIcons.wrench,
      ),
    );
  }
}
