import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_orders/widgets/orders_items.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

@RoutePage()
class WorkOrdersPage extends StatelessWidget {
  const WorkOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      isScrollable: false,
      onRefresh: context
          .read<WorkOrdersCubit>()
          .loadWorkOrdersAndChangeRequests,
      appBar: BaseAppBar(
        title: 'Ordens de serviço'.hardcoded,
        leading: BaseIconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          platformIcon: const PlatformIcon(
            materialIcon: Icons.menu,
            cupertinoIcon: CupertinoIcons.bars,
          ),
        ),
        actions: [
          Builder(
            builder: (context) {
              final assetHasError = context.select<AssetsCubit, bool>(
                (cubit) => cubit.state.errorMessage?.isNotEmpty ?? false,
              );
              final locationsHasError = context.select<LocationsCubit, bool>(
                (cubit) => cubit.state.errorMessage?.isNotEmpty ?? false,
              );
              final categoriesHasError = context.select<CategoriesCubit, bool>(
                (cubit) => cubit.state.errorMessage?.isNotEmpty ?? false,
              );
              return BaseIconButton(
                permission: const ActionPermission(
                  resource: ResourceType.workOrders,
                  action: PermissionAction.create,
                ),
                onPressed:
                    assetHasError || locationsHasError || categoriesHasError
                    ? null
                    : () => context.router.push(CreateUpdateWorkOrderRoute()),
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.add,
                  cupertinoIcon: CupertinoIcons.add,
                ),
              );
            },
          ),
        ],
      ),
      body: const OrdersItems(),
    );
  }
}
