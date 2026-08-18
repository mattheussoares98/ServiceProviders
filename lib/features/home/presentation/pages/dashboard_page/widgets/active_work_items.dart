import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/active_stopwatch_card.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

class ActiveWorkItems extends StatelessWidget {
  const ActiveWorkItems({super.key});

  @override
  Widget build(BuildContext context) {
    final workOrdersCubit = context.read<WorkOrdersCubit>();
    final activeWorkOrders = context
        .select<WorkOrdersCubit, List<WorkOrderEntity>>(
          (cubit) => cubit.state.workOrders
              .where((wo) => wo.status == WorkOrderStatus.inProgress)
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
        );

    if (activeWorkOrders.isEmpty) {
      return const SizedBox.shrink();
    }

    const height = 130.0;
    Widget child;
    if (context.screenType == ScreenType.compact ||
        context.screenType == ScreenType.phone) {
      child = SizedBox(
        height: height,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: activeWorkOrders.length,
          itemBuilder: (context, index) {
            final workOrder = activeWorkOrders[index];
            return SizedBox(
              width: 300,
              height: height,
              child: Padding(
                padding: const EdgeInsets.only(right: Sizes.p8),
                child: ActiveStopwatchCard(
                  workOrder: workOrder,
                  onTap: () =>
                      workOrdersCubit.navigateToWorkOrderDetails(workOrder.id),
                ),
              ),
            );
          },
        ),
      );
    } else {
      child = Center(
        child: Wrap(
          spacing: Sizes.p8,
          runSpacing: Sizes.p8,
          children: activeWorkOrders.map((workOrder) {
            return SizedBox(
              width: 300,
              height: height,
              child: ActiveStopwatchCard(
                workOrder: workOrder,
                onTap: () =>
                    workOrdersCubit.navigateToWorkOrderDetails(workOrder.id),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Column(
      children: [
        gapH8,
        BaseText.title('TRABALHOS EM ANDAMENTO'.hardcoded),
        gapH4,
        child,
        gapH12,
      ],
    );
  }
}

