import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_list_tile.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_state_view.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersItems extends StatelessWidget {
  const OrdersItems({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseStateView<
      WorkOrdersCubit,
      WorkOrdersState,
      List<WorkOrderEntity>
    >(
      dataSelector: (state) => state.workOrders,
      onRetry: context.read<WorkOrdersCubit>().loadWorkOrdersAndChangeRequests,
      builder: (context, workOrders) {
        if (workOrders.isEmpty) {
          return BaseText.error('Nenhuma ordem foi encontrada'.hardcoded);
        }

        return ListView.builder(
          itemCount: workOrders.length,
          itemBuilder: (context, index) {
            final workOrder = workOrders[index];
            return BaseListTile(
              title: workOrder.title,
              subtitle: workOrder.description,
              platformIcon: const PlatformIcon(
                materialIcon: Icons.build,
                cupertinoIcon: CupertinoIcons.settings,
              ),
              onTap: () {},
            );
          },
        );
      },
    );
  }
}
