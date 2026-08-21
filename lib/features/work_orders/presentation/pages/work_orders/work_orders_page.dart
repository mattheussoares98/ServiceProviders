import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/widgets/open_drawer_icon_button.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/widgets/orders_items.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/widgets/work_order_filters.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';

@RoutePage()
class WorkOrdersPage extends StatelessWidget {
  const WorkOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO check this entire page because of the last changes
    return BaseScaffold(
      isScrollable: false,
      onRefresh: context
          .read<WorkOrdersCubit>()
          .loadWorkOrdersAndChangeRequests,
      appBar: BaseAppBar(
        title: 'Ordens de serviço'.hardcoded,
        leading: const OpenDrawerIconButton(),
        actions: [
          BaseIconButton(
            onPressed: () {
              showModalPage<void>(
                WorkOrderFilters(
                  currentFilter: context
                      .read<WorkOrdersCubit>()
                      .state
                      .activeFilter,
                ),
                context,
              );
            },
            platformIcon: const PlatformIcon(
              materialIcon: Icons.filter_list,
              cupertinoIcon: CupertinoIcons.slider_horizontal_3,
            ),
          ),
          Builder(
            builder: (context) {
              return BaseIconButton(
                permission: const ActionPermission.resource(
                  resourceType: ResourceType.workOrders,
                  permissionAction: PermissionAction.create,
                ),
                onPressed: () => context
                    .read<WorkOrdersCubit>()
                    .navigateToCreateUpdateWorkOrder(null),
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
