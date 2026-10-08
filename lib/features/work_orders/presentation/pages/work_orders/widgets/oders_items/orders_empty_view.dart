part of '../../../widgets/orders_items.dart';

class _OrdersEmptyView extends StatelessWidget {
  const _OrdersEmptyView();

  @override
  Widget build(BuildContext context) {
    final hasFilter = context.select<WorkOrdersCubit, bool>(
      (c) => c.state.activeFilter != const WorkOrderFilter(),
    );
    final hasWorkOrders = context.select<WorkOrdersCubit, bool>(
      (c) => c.state.hasWorkOrders,
    );

    if (hasFilter || hasWorkOrders) {
      return const _NoOrdersFoundView();
    }

    final workType = context.select<CompanyCubit, WorkType>(
      (c) => c.state.company?.workType ?? WorkType.hybrid,
    );
    final (hasLocations, hasAreas) = context
        .select<LocationsCubit, (bool, bool)>(
          (c) => (c.state.hasLocations, c.state.hasAreas),
        );
    final hasCustomers = context.select<CustomersCubit, bool>(
      (c) => c.state.hasCustomers,
    );
    final hasAssets = context.select<AssetsCubit, bool>(
      (c) => c.state.hasAssets,
    );
    final hasLocationCreate = context.hasPermission(
      const ActionPermission.resource(
        resourceType: ResourceType.locations,
        permissionAction: PermissionAction.create,
      ),
    );
    final hasAssetCreate = context.hasPermission(
      const ActionPermission.resource(
        resourceType: ResourceType.assets,
        permissionAction: PermissionAction.create,
      ),
    );

    final eval = context.read<WorkOrdersCubit>().evaluatePrerequisites(
      EvaluatePrerequisitesParams(
        workType: workType,
        hasLocations: hasLocations,
        hasAreas: hasAreas,
        hasCustomers: hasCustomers,
        hasAssets: hasAssets,
        hasLocationCreatePermission: hasLocationCreate,
        hasAssetCreatePermission: hasAssetCreate,
      ),
    );

    final isPrerequisitesLoading =
        context.select<CompanyCubit, bool>(
          (c) =>
              c.state.sections[BaseSections.load]?.status ==
              SectionStatus.running,
        ) ||
        context.select<LocationsCubit, bool>(
          (c) =>
              c.state.sections[BaseSections.load]?.status ==
              SectionStatus.running,
        ) ||
        context.select<CustomersCubit, bool>(
          (c) =>
              c.state.sections[BaseSections.load]?.status ==
              SectionStatus.running,
        ) ||
        context.select<AssetsCubit, bool>(
          (c) =>
              c.state.sections[BaseSections.load]?.status ==
              SectionStatus.running,
        );

    if (isPrerequisitesLoading) {
      return const LoadingCircle();
    } else if (eval.hasPendingRequiredPrerequisites) {
      return PrerequisiteGuideCard(steps: eval.steps);
    } else if (!hasWorkOrders) {
      return BaseEmptyState(
        title: 'Criar ordem de serviço'.hardcoded,
        description:
            'Crie sua primeira ordem de serviço para começar a gerenciar suas tarefas'
                .hardcoded,
        actionLabel: 'Criar ordem de serviço'.hardcoded,
        onAction: () => context
            .read<WorkOrdersCubit>()
            .navigateToCreateUpdateWorkOrder(null),
        icon: const PlatformIcon(
          materialIcon: Icons.assignment_outlined,
          cupertinoIcon: CupertinoIcons.doc_text,
        ),
      );
    }

    return const _NoOrdersFoundView();
  }
}

class _NoOrdersFoundView extends StatelessWidget {
  const _NoOrdersFoundView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: BaseText.error('Nenhuma ordem foi encontrada'.hardcoded),
          ),
        ),
      ],
    );
  }
}
