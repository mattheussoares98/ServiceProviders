import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/active_stopwatch_card.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

class ActiveWorkItems extends StatelessWidget {
  const ActiveWorkItems({super.key});

  @override
  Widget build(BuildContext context) {
    final activeWorkOrders = context
        .select<DashboardCubit, List<WorkOrderEntity>>(
          (cubit) => cubit.state.activeWorkOrders,
        );

    Widget child;
    if (context.screenType == ScreenType.compact ||
        context.screenType == ScreenType.phone) {
      child = SizedBox(
        height: 105,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: activeWorkOrders.length,
          itemBuilder: (context, index) {
            final workOrder = activeWorkOrders[index];
            return SizedBox(
              width: 300,
              height: 105,
              child: Padding(
                padding: const EdgeInsets.only(right: Sizes.p8),
                child: ActiveStopwatchCard(
                  workOrder: workOrder,
                  onTap: () => context.router.push(
                    CreateUpdateWorkOrderRoute(workOrder: workOrder),
                  ),
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
              height: 105,
              child: ActiveStopwatchCard(
                workOrder: workOrder,
                onTap: () => context.router.push(
                  CreateUpdateWorkOrderRoute(workOrder: workOrder),
                ),
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
