import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_list_tile.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_state_view.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
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
            appBar: BaseAppBar(
              title: 'Ordens de Serviço'.hardcoded,
              leading: BaseIconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.menu,
                  cupertinoIcon: CupertinoIcons.bars,
                ),
              ),
            ),
            body:
                BaseStateView<
                  WorkOrdersCubit,
                  WorkOrdersState,
                  List<WorkOrderEntity>
                >(
                  dataSelector: (state) => state.workOrders,
                  onRetry: context
                      .read<WorkOrdersCubit>()
                      .loadWorkOrdersAndChangeRequests,
                  builder: (context, workOrders) {
                    if (workOrders.isEmpty) {
                      return Center(
                        child: BaseText.titleMedium(
                          'Nenhum local cadastrado'.hardcoded,
                          color: Colors.red,
                        ),
                      );
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
                ),
          );
        },
      ),
    );
  }
}
