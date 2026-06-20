import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/create_work_order_form.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/orders_items.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/show_modal_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        title: 'Ordens de Serviço'.hardcoded,
        leading: BaseIconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          platformIcon: const PlatformIcon(
            materialIcon: Icons.menu,
            cupertinoIcon: CupertinoIcons.bars,
          ),
        ),
        actions: [
          BaseIconButton(
            onPressed: () {
              showModalPage<void>(
                BlocProvider.value(
                  value: context.read<WorkOrdersCubit>(),
                  child: const CreateWorkOrderForm(),
                ),
                context,
              );
            },
            platformIcon: const PlatformIcon(
              materialIcon: Icons.add,
              cupertinoIcon: CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body: const OrdersItems(),
    );
  }
}
