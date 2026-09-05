import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/presentation/extensions/access_log_action_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class AccessLogItemCard extends StatelessWidget {
  const AccessLogItemCard({super.key, required this.log});

  final AccessLogEntity log;

  @override
  Widget build(BuildContext context) {
    final actionColor = log.action.color;
    final userDisplayName = (log.userName != null && log.userName!.isNotEmpty)
        ? log.userName!
        : (log.userEmail != null && log.userEmail!.isNotEmpty)
        ? log.userEmail!
        : log.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: Sizes.p12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.p12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p12),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Wrap(
              spacing: Sizes.p8,
              runSpacing: Sizes.p8,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.p8,
                    vertical: Sizes.p4,
                  ),
                  decoration: BoxDecoration(
                    color: actionColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Sizes.p8),
                    border: Border.all(
                      color: actionColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      log.action.platformIcon,
                      gapW4,
                      Flexible(
                        child: BaseText.bodySmall(
                          log.action.label,
                          fontWeight: FontWeight.bold,
                          color: actionColor,
                        ),
                      ),
                    ],
                  ),
                ),
                BaseText.caption(
                  log.createdAt.toLocal().formatDate(
                    DateFormatType.ddMMyyyyHHmmss,
                  ),
                ),
              ],
            ),
            gapH8,
            Row(
              children: [
                PlatformIcon(
                  materialIcon: Icons.person_outline,
                  cupertinoIcon: CupertinoIcons.person,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                gapW8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BaseText.bodyMedium(
                        userDisplayName,
                        fontWeight: FontWeight.w600,
                      ),
                      if (log.userEmail != null &&
                          log.userEmail!.isNotEmpty &&
                          log.userEmail != log.userName)
                        BaseText.caption(
                          log.userEmail!,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if ((log.ipAddress != null && log.ipAddress!.isNotEmpty) ||
                (log.deviceInfo != null && log.deviceInfo!.isNotEmpty)) ...[
              gapH8,
              const Divider(height: 1),
              gapH8,
              Wrap(
                spacing: Sizes.p16,
                runSpacing: Sizes.p4,
                children: [
                  if (log.ipAddress != null && log.ipAddress!.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PlatformIcon(
                          materialIcon: Icons.language,
                          cupertinoIcon: CupertinoIcons.globe,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        gapW4,
                        BaseText.caption(
                          log.ipAddress!,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  if (log.deviceInfo != null && log.deviceInfo!.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PlatformIcon(
                          materialIcon: Icons.devices_outlined,
                          cupertinoIcon: CupertinoIcons.device_phone_portrait,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        gapW4,
                        Flexible(
                          child: BaseText.caption(
                            log.deviceInfo!,
                            color: context.colorScheme.onSurfaceVariant,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
