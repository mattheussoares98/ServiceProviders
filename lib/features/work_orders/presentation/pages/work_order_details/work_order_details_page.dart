import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachments.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/edit_and_delete_icons.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/info_items.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

@RoutePage()
class WorkOrderDetailsPage extends StatelessWidget {
  const WorkOrderDetailsPage({super.key, required this.workOrderId});

  final String workOrderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<AttachmentsCubit>()..init(workOrderId),
      child: BlocSelector<WorkOrdersCubit, WorkOrdersState, WorkOrderEntity?>(
        selector: (state) =>
            state.workOrders.firstWhereOrNull((e) => e.id == workOrderId),
        builder: (context, workOrder) {
          if (workOrder == null) {
            return BaseScaffold(
              appBar: BaseAppBar(
                title: 'Detalhes da ordem de serviço'.hardcoded,
              ),
              body: Center(
                child: BaseText.error(
                  'Ordem de serviço não encontrada'.hardcoded,
                ),
              ),
            );
          }
          return _WorkOrderDetails(workOrder: workOrder);
        },
      ),
    );
  }
}

class _WorkOrderDetails extends HookWidget {
  const _WorkOrderDetails({required this.workOrder});
  final WorkOrderEntity workOrder;

  @override
  Widget build(BuildContext context) {
    observeLoading(
      [context.read<WorkOrdersCubit>()],
      statuses: {StateStatus.deleting},
    );

    return BaseScaffold(
      isScrollable: false,
      appBar: BaseAppBar(
        title: 'Detalhes da ordem de serviço'.hardcoded,
        actions: [EditAndDeleteIcons(workOrderId: workOrder.id)],
      ),
      body: CustomScrollView(
        slivers: [
          InfoItems(workOrder: workOrder),
          Attachments(workOrderId: workOrder.id, isEditing: false),
        ],
      ),
    );
  }
}
