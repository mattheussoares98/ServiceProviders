import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/presentation/widgets/work_order_item.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentWorkOrders extends StatelessWidget {
  const RecentWorkOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final recentWorkOrders = context
        .select<DashboardCubit, List<WorkOrderEntity>>(
          (cubit) => cubit.state.recentWorkOrders,
        );

    return Column(
      crossAxisAlignment: .start,
      children: [
        BaseText.title('Ordens recentes'.hardcoded),
        gapH4,
        if (recentWorkOrders.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Sizes.p24),
              child: BaseText('Nenhuma ordem de serviço recente.'.hardcoded),
            ),
          )
        else
          ...recentWorkOrders.map(
            (workOrder) => WorkOrderItem(workOrder: workOrder),
          ),
        gapH16,
      ],
    );
  }
}
