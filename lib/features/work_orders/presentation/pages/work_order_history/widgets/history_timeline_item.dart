import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class HistoryTimelineItem extends StatelessWidget {
  const HistoryTimelineItem({
    super.key,
    required this.item,
    required this.isLast,
  });

  final WorkOrderHistoryEntity item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final user = context.select<UsersCubit, UserProfileEntity?>(
      (cubit) => cubit.state.users.firstWhereOrNull((u) => u.id == item.userId),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.primary,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: context.colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
          gapW16,
          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: Sizes.p16),
              padding: const EdgeInsets.all(Sizes.p16),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(Sizes.p12),
                border: Border.all(color: context.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: BaseText.bodyMedium(
                          item.action.hardcoded,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      BaseText.caption(item.createdAt.formatDate()),
                    ],
                  ),
                  if (item.oldValue != null || item.newValue != null) ...[
                    gapH8,
                    if (item.oldValue != null)
                      BaseText.bodySmall(
                        'De: ${item.oldValue}'.hardcoded,
                        color: context.colorScheme.error,
                      ),
                    if (item.newValue != null)
                      BaseText.bodySmall(
                        'Para: ${item.newValue}'.hardcoded,
                        color: context.colorScheme.primary,
                      ),
                  ],
                  gapH8,
                  BaseText.caption(
                    'Por: ${user?.name ?? item.userId}'.hardcoded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
