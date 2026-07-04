import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:clean_architecture/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/create_update_work_order_form.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_indication_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_state_view.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/show_modal_page.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
        final isDeleting = context.select((WorkOrdersCubit cubit) {
          //TODO add the deletingIds to treat it by each one
          return cubit.state.status == StateStatus.deleting;
        });

        return ListView.builder(
          itemCount: workOrders.length,
          itemBuilder: (context, index) {
            final workOrder = workOrders[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.p8),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    BaseText.title(workOrder.title),
                    gapH4,
                    if (workOrder.description != null)
                      BaseText(
                        workOrder.description!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    gapH8,
                    RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: BaseIndicationItem(
                              label: workOrder.type.label,
                              color: workOrder.type.color,
                            ),
                          ),
                          const WidgetSpan(child: gapW4),
                          WidgetSpan(
                            child: BaseIndicationItem(
                              label: workOrder.priority.label,
                              color: workOrder.priority.color,
                            ),
                          ),
                          const WidgetSpan(child: gapW4),
                          WidgetSpan(
                            child: BaseIndicationItem(
                              label: workOrder.status.label,
                              color: workOrder.status.color,
                            ),
                          ),
                          if (workOrder.estimatedDuration != null) ...[
                            const WidgetSpan(child: gapW4),
                            WidgetSpan(
                              child: BaseIndicationItem(
                                label: '${workOrder.estimatedDuration} min',
                                color: workOrder.status.color,
                              ),
                            ),
                          ],
                          if (workOrder.scheduledDate != null) ...[
                            const WidgetSpan(child: gapW4),
                            WidgetSpan(
                              child: BaseIndicationItem(
                                label: DateFormat.yMMMMd().format(
                                  workOrder.scheduledDate!,
                                ),
                                color: workOrder.status.color,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        BaseIconButton(
                          permission: const ActionPermission(
                            resource: ResourceType.workOrders,
                            action: PermissionAction.delete,
                          ),
                          isLoading: isDeleting,
                          onPressed: () {
                            showAlertDialog(
                              context: context,
                              title: 'Atenção!'.hardcoded,
                              contentText:
                                  'Deseja realmente excluir a ordem de serviço?'
                                      .hardcoded,
                              defaultActionText: 'Sim'.hardcoded,
                              cancelActionText: 'Não'.hardcoded,
                              onOkPressed: () => context
                                  .read<WorkOrdersCubit>()
                                  .deleteWorkOrder(workOrder.id),
                            );
                          },
                          platformIcon: const PlatformIcon(
                            materialIcon: Icons.delete,
                            cupertinoIcon: CupertinoIcons.delete,
                            color: Colors.red,
                          ),
                        ),
                        Flexible(
                          child: BaseTextButton(
                            permission: const ActionPermission(
                              resource: ResourceType.workOrders,
                              action: PermissionAction.update,
                            ),
                            text: 'Editar'.hardcoded,
                            onPressed: isDeleting
                                ? null
                                : () {
                                    showModalPage<void>(
                                      BlocProvider.value(
                                        value: context.read<WorkOrdersCubit>(),
                                        child: CreateUpdateWorkOrderForm(
                                          workOrder: workOrder,
                                        ),
                                      ),
                                      context,
                                    );
                                  },
                            platformIcon: const PlatformIcon(
                              materialIcon: Icons.edit,
                              cupertinoIcon: CupertinoIcons.pencil,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
