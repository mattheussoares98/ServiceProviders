import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite_step.dart';

class EvaluatePrerequisitesParams extends Equatable {
  const EvaluatePrerequisitesParams({
    required this.workType,
    required this.locationsCount,
    required this.areasCount,
    required this.customersCount,
    this.assetsCount = 0,
    this.hasLocationCreatePermission = true,
    this.hasCustomerCreatePermission = true,
    this.hasAssetCreatePermission = true,
  });

  final WorkType workType;
  final int locationsCount;
  final int areasCount;
  final int customersCount;
  final int assetsCount;
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
            isCompleted: params.locationsCount > 0,
            canPerformAction: params.hasLocationCreatePermission,
          ),
          PrerequisiteStep(
            type: PrerequisiteType.area,
            title: 'Cadastrar área'.hardcoded,
            description:
                'Subdivisões do local (ex: salas, andares ou setores).'
                    .hardcoded,
            actionLabel: 'Cadastrar Área'.hardcoded,
            permissionRequired: const ActionPermission.resource(
              resourceType: ResourceType.locations,
              permissionAction: PermissionAction.create,
            ),
            isCompleted: params.areasCount > 0,
            isOptional: true,
            canPerformAction: params.hasLocationCreatePermission,
          ),
          PrerequisiteStep(
            type: PrerequisiteType.asset,
            title: 'Cadastrar equipamento'.hardcoded,
            description:
                'Máquinas ou aparelhos que recebem ordens de serviço.'
                    .hardcoded,
            actionLabel: 'Cadastrar Equipamento'.hardcoded,
            permissionRequired: const ActionPermission.resource(
              resourceType: ResourceType.assets,
              permissionAction: PermissionAction.create,
            ),
            isCompleted: params.assetsCount > 0,
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
            isCompleted: params.customersCount > 0,
            canPerformAction: params.hasCustomerCreatePermission,
          ),
          PrerequisiteStep(
            type: PrerequisiteType.asset,
            title: 'Cadastrar equipamento do cliente'.hardcoded,
            description:
                'Equipamentos atendidos ou ferramentas de trabalho.'
                    .hardcoded,
            actionLabel: 'Cadastrar Equipamento'.hardcoded,
            permissionRequired: const ActionPermission.resource(
              resourceType: ResourceType.assets,
              permissionAction: PermissionAction.create,
            ),
            isCompleted: params.assetsCount > 0,
            isOptional: true,
            canPerformAction: params.hasAssetCreatePermission,
          ),
        ];

      case WorkType.hybrid:
        final hasLocationOrCustomer =
            params.locationsCount > 0 || params.customersCount > 0;
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
                'Empresas ou parceiros que solicitam serviços.'
                    .hardcoded,
            actionLabel: 'Cadastrar Cliente'.hardcoded,
            isCompleted: params.customersCount > 0,
            isOptional: true,
            canPerformAction: params.hasCustomerCreatePermission,
          ),
          PrerequisiteStep(
            type: PrerequisiteType.asset,
            title: 'Cadastrar equipamento'.hardcoded,
            description:
                'Equipamentos ou máquinas sob manutenção.'
                    .hardcoded,
            actionLabel: 'Cadastrar Equipamento'.hardcoded,
            permissionRequired: const ActionPermission.resource(
              resourceType: ResourceType.assets,
              permissionAction: PermissionAction.create,
            ),
            isCompleted: params.assetsCount > 0,
            isOptional: true,
            canPerformAction: params.hasAssetCreatePermission,
          ),
        ];
    }

    return PrerequisiteEvaluationResult(steps: steps);
  }
}
