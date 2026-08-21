import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';

/// Loads the location, area and asset labels the provider work order pages show.
///
/// In provider mode those cubits cannot load by company — the rows belong to the
/// contracting companies — so they are fed the ids the loaded work orders point
/// at, which is exactly what RLS grants a provider access to.
class ProviderLookupsLoader extends StatelessWidget {
  const ProviderLookupsLoader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkOrdersCubit, WorkOrdersState>(
      listenWhen: (previous, current) =>
          previous.workOrders != current.workOrders,
      listener: (context, state) {
        final workOrders = state.workOrders;
        context.read<LocationsCubit>().loadLocationsAndAreasByIds(
          locationIds: _uniqueIds(workOrders, (order) => order.locationId),
          areaIds: _uniqueIds(workOrders, (order) => order.areaId),
        );
        context.read<AssetsCubit>().loadAssetsByIds(
          _uniqueIds(workOrders, (order) => order.assetId),
        );
      },
      child: child,
    );
  }

  List<String> _uniqueIds(
    List<WorkOrderEntity> workOrders,
    String? Function(WorkOrderEntity) selector,
  ) => workOrders.map(selector).nonNulls.toSet().toList();
}
