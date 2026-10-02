import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite/prerequisite_step.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite/prerequisite_type.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/prerequisites/prerequisite_guide_card.dart';

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
      return PrerequisiteGuideCard(
        title: 'Pré-requisitos para equipamentos'.hardcoded,
        subtitle: 'Cadastre um local para poder vincular seus equipamentos:'
            .hardcoded,
        steps: [
          PrerequisiteStep(
            type: PrerequisiteType.location,
            title: 'Cadastrar local'.hardcoded,
            description: 'Locais físicos onde os equipamentos estão instalados.'
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
        subtitle: 'Cadastre um cliente para poder vincular seus equipamentos:'
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
}
