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

    final eval = const EvaluatePrerequisitesUseCase()(
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

    if (eval.hasPendingRequiredPrerequisites) {
      return PrerequisiteGuideCard(steps: eval.steps);
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
