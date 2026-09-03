import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_log_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class HistoryTimelineItem extends StatelessWidget {
  const HistoryTimelineItem({
    super.key,
    required this.item,
    required this.isLast,
  });

  final AuditLogEntity item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final user = context.select<UsersCubit, UserProfileEntity?>(
      (cubit) => cubit.state.users.firstWhereOrNull((u) => u.id == item.userId),
    );

    final fileUrl = item.metadata?['file_url'] as String?;
    final fileName = item.metadata?['file_name'] as String?;

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
                          (item.summary ?? item.action).hardcoded,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      BaseText.caption(item.createdAt.formatDate()),
                    ],
                  ),
                  if (item.changes.isNotEmpty) ...[
                    gapH8,
                    ...item.changes.map((change) {
                      final oldVal = change.effectiveOldValue;
                      final newVal = change.effectiveNewValue;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Sizes.p4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BaseText.bodySmall(
                              change.effectiveLabel.hardcoded,
                              fontWeight: FontWeight.w600,
                            ),
                            if (oldVal != null)
                              BaseText.bodySmall(
                                'De: $oldVal'.hardcoded,
                                color: context.colorScheme.error,
                              ),
                            if (newVal != null)
                              BaseText.bodySmall(
                                'Para: $newVal'.hardcoded,
                                color: context.colorScheme.primary,
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                  if (fileUrl != null && fileUrl.isNotEmpty) ...[
                    gapH8,
                    SecondaryButton(
                      text: (fileName != null && fileName.isNotEmpty)
                          ? 'Abrir anexo ($fileName)'.hardcoded
                          : 'Abrir anexo'.hardcoded,
                      platformIcon: const PlatformIcon(
                        materialIcon: Icons.attach_file,
                        cupertinoIcon: CupertinoIcons.paperclip,
                      ),
                      onTap: () => GetIt.I<FileService>().openFile(fileUrl),
                    ),
                  ],
                  gapH8,
                  BaseText.caption(
                    'Por: ${user?.name ?? item.userId ?? 'Sistema'}'.hardcoded,
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
