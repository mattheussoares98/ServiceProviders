import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/orders_appbar.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/orders_items.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class WorkOrdersPage extends StatelessWidget {
  const WorkOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<WorkOrdersCubit>()..loadWorkOrdersAndChangeRequests(),
      child: Builder(
        builder: (context) {
          return BaseScaffold(
            onRefresh: context
                .read<WorkOrdersCubit>()
                .loadWorkOrdersAndChangeRequests,
            appBar: const OrdersAppbar(),
            body: const OrdersItems(),
          );
        },
      ),
    );
  }
}
