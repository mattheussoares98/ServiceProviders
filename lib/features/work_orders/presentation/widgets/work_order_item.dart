import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/date_time_extension.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_indication_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                permission: const ActionPermission(
                  resource: ResourceType.workOrders,
                  action: PermissionAction.update,
                ),
                text: 'Editar'.hardcoded,
                onPressed: () => context.router.push(
                  CreateUpdateWorkOrderRoute(workOrder: workOrder),
                ),
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.edit,
                  cupertinoIcon: CupertinoIcons.pencil,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
