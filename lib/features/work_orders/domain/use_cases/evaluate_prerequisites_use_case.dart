import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite/prerequisite_evaluation_result.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite/prerequisite_step.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite/prerequisite_type.dart';

class EvaluatePrerequisitesParams extends Equatable {
  const EvaluatePrerequisitesParams({
    required this.workType,
    this.locationsCount = 0,
    this.areasCount = 0,
    this.customersCount = 0,
    this.assetsCount = 0,
    bool? hasLocations,
    bool? hasAreas,
    bool? hasCustomers,
    bool? hasAssets,
    this.hasLocationCreatePermission = true,
    this.hasCustomerCreatePermission = true,
    this.hasAssetCreatePermission = true,
  }) : hasLocations = hasLocations ?? (locationsCount > 0),
       hasAreas = hasAreas ?? (areasCount > 0),
       hasCustomers = hasCustomers ?? (customersCount > 0),
       hasAssets = hasAssets ?? (assetsCount > 0);

  final WorkType workType;
  final int locationsCount;
  final int areasCount;
  final int customersCount;
  final int assetsCount;
  final bool hasLocations;
  final bool hasAreas;
  final bool hasCustomers;
  final bool hasAssets;
  final bool hasLocationCreatePermission;
  final bool hasCustomerCreatePermission;
  final bool hasAssetCreatePermission;

  @override
  List<Object?> get props => [
    workType,
    locationsCount,
    areasCount,
    customersCount,
    assetsCount,
    hasLocations,
    hasAreas,
    hasCustomers,
    hasAssets,
    hasLocationCreatePermission,
    hasCustomerCreatePermission,
    hasAssetCreatePermission,
  ];
}

@LazySingleton()
class EvaluatePrerequisitesUseCase
    implements
        UseCaseSynchronous<
          PrerequisiteEvaluationResult,
          EvaluatePrerequisitesParams
        > {
  const EvaluatePrerequisitesUseCase();

  @override
  PrerequisiteEvaluationResult call(EvaluatePrerequisitesParams params) {
    final List<PrerequisiteStep> steps;

    switch (params.workType) {
      case WorkType.internalOnly:
        steps = [
          PrerequisiteStep(
            type: PrerequisiteType.location,
            title: 'Cadastrar local'.hardcoded,
            description:
                'Locais físicos ou unidades onde manutenções são executadas.'
                    .hardcoded,
            actionLabel: 'Cadastrar Local'.hardcoded,
            permissionRequired: const ActionPermission.resource(
              resourceType: ResourceType.locations,
              permissionAction: PermissionAction.create,
            ),
            isCompleted: params.hasLocations,
            canPerformAction: params.hasLocationCreatePermission,
          ),
          PrerequisiteStep(
            type: PrerequisiteType.area,
            title: 'Cadastrar área'.hardcoded,
            description: 'Subdivisões do local (ex: salas, andares ou setores).'
                .hardcoded,
            actionLabel: 'Cadastrar Área'.hardcoded,
            permissionRequired: const ActionPermission.resource(
              resourceType: ResourceType.locations,
              permissionAction: PermissionAction.create,
            ),
            isCompleted: params.hasAreas,
            isOptional: true,
            canPerformAction: params.hasLocationCreatePermission,
          ),
          PrerequisiteStep(
            type: PrerequisiteType.asset,
            title: 'Cadastrar equipamento'.hardcoded,
            description: 'Máquinas ou aparelhos que recebem ordens de serviço.'
                .hardcoded,
            actionLabel: 'Cadastrar Equipamento'.hardcoded,
            permissionRequired: const ActionPermission.resource(
              resourceType: ResourceType.assets,
              permissionAction: PermissionAction.create,
            ),
            isCompleted: params.hasAssets,
            isOptional: true,
            canPerformAction: params.hasAssetCreatePermission,
          ),
        ];

      case WorkType.serviceProviderOnly:
        steps = [
          PrerequisiteStep(
            type: PrerequisiteType.customer,
            title: 'Cadastrar cliente'.hardcoded,
            description:
                'Clientes externos que contratam seus serviços de manutenção.'
                    .hardcoded,
            actionLabel: 'Cadastrar Cliente'.hardcoded,
            isCompleted: params.hasCustomers,
            canPerformAction: params.hasCustomerCreatePermission,
          ),
          PrerequisiteStep(
            type: PrerequisiteType.asset,
            title: 'Cadastrar equipamento do cliente'.hardcoded,
            description:
                'Equipamentos atendidos ou ferramentas de trabalho.'.hardcoded,
            actionLabel: 'Cadastrar Equipamento'.hardcoded,
            permissionRequired: const ActionPermission.resource(
              resourceType: ResourceType.assets,
              permissionAction: PermissionAction.create,
            ),
            isCompleted: params.hasAssets,
            isOptional: true,
            canPerformAction: params.hasAssetCreatePermission,
          ),
        ];

      case WorkType.hybrid:
        final hasLocationOrCustomer =
            params.hasLocations || params.hasCustomers;
        steps = [
          PrerequisiteStep(
            type: PrerequisiteType.location,
            title: 'Cadastrar local ou cliente'.hardcoded,
            description:
                'Cadastre sua primeira unidade própria ou cliente atendido.'
                    .hardcoded,
            actionLabel: 'Cadastrar Local'.hardcoded,
            isCompleted: hasLocationOrCustomer,
            canPerformAction:
                params.hasLocationCreatePermission ||
                params.hasCustomerCreatePermission,
          ),
          PrerequisiteStep(
            type: PrerequisiteType.customer,
            title: 'Cadastrar cliente externo'.hardcoded,
            description:
                'Empresas ou parceiros que solicitam serviços.'.hardcoded,
            actionLabel: 'Cadastrar Cliente'.hardcoded,
            isCompleted: params.hasCustomers,
            isOptional: true,
            canPerformAction: params.hasCustomerCreatePermission,
          ),
          PrerequisiteStep(
            type: PrerequisiteType.asset,
            title: 'Cadastrar equipamento'.hardcoded,
            description: 'Equipamentos ou máquinas sob manutenção.'.hardcoded,
            actionLabel: 'Cadastrar Equipamento'.hardcoded,
            permissionRequired: const ActionPermission.resource(
              resourceType: ResourceType.assets,
              permissionAction: PermissionAction.create,
            ),
            isCompleted: params.hasAssets,
            isOptional: true,
            canPerformAction: params.hasAssetCreatePermission,
          ),
        ];
    }

    return PrerequisiteEvaluationResult(steps: steps);
  }
}
