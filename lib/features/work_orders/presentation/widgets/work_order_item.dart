import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_indication_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_rich_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class WorkOrderItem extends StatelessWidget {
  const WorkOrderItem({super.key, required this.workOrder});
  final WorkOrderEntity workOrder;

  @override
  Widget build(BuildContext context) {
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
            BaseRichText(
              texts: [
                const BaseText('Criado em: ', fontWeight: FontWeight.bold),
                BaseText(
                  workOrder.createdAt.formatDate(DateFormatType.ddMMyyyyHHmm),
                ),
              ],
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
                        label: workOrder.scheduledDate!.formatDate(
                          DateFormatType.yMMMMd,
                        ),
                        color: workOrder.status.color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            BlocSelector<UsersCubit, UsersState, UserProfileEntity?>(
              selector: (state) => state.users.firstWhereOrNull(
                (e) => e.id == workOrder.assignedToId,
              ),
              builder: (context, user) {
                if (user == null) {
                  return const SizedBox.shrink();
                }
                return Align(
                  alignment: .centerLeft,
                  child: BaseText(user.name, fontWeight: FontWeight.bold),
                );
              },
            ),
            Align(
              alignment: .centerRight,
              child: BaseTextButton(
                permission: const ActionPermission.resource(
                  resource: ResourceType.workOrders,
                  action: PermissionAction.update,
                ),
                text: 'Detalhes'.hardcoded,
                onPressed: () => context
                    .read<WorkOrdersCubit>()
                    .navigateToWorkOrderDetails(workOrder.id),
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.info,
                  cupertinoIcon: CupertinoIcons.info,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
