import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/widgets/work_order_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class RecentWorkOrders extends StatelessWidget {
  const RecentWorkOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final recentWorkOrders = context
        .select<WorkOrdersCubit, List<WorkOrderEntity>>(
          (cubit) => [...cubit.state.workOrders]
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
        )
        .take(5)
        .toList();

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [BaseText.title('Ordens recentes'.hardcoded), gapH4],
          ),
        ),
        if (recentWorkOrders.isEmpty)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Sizes.p24),
                child: BaseText('Nenhuma ordem de serviço recente.'.hardcoded),
              ),
            ),
          )
        else
          ResponsiveListFlow(
            isSliver: true,
            itemCount: recentWorkOrders.length,
            itemBuilder: (context, index) {
              final workOrder = recentWorkOrders[index];
              return WorkOrderItem(workOrder: workOrder);
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: Sizes.p16)),
      ],
    );
  }
}

