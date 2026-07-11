import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/title_and_subtitle.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

class InfoItems extends StatelessWidget {
  const InfoItems({super.key, required this.workOrder});
  final WorkOrderEntity workOrder;

  @override
  Widget build(BuildContext context) {
    final user = context.select<UsersCubit, UserProfileEntity?>(
      (cubit) => cubit.state.users.firstWhereOrNull(
        (e) => e.id == workOrder.assignedToId,
      ),
    );
    final location = context.select<LocationsCubit, LocationEntity?>(
      (cubit) => cubit.state.locations.firstWhereOrNull(
        (e) => e.id == workOrder.locationId,
      ),
    );
    final asset = context.select<AssetsCubit, AssetEntity?>(
      (cubit) =>
          cubit.state.assets.firstWhereOrNull((e) => e.id == workOrder.assetId),
    );

    final items = [
      TitleAndSubtitle(
        title: 'Título'.hardcoded,
        subtitle: workOrder.title,
        icon: const PlatformIcon(
          materialIcon: Icons.assignment_outlined,
          cupertinoIcon: CupertinoIcons.doc_text,
        ),
      ),
      TitleAndSubtitle(
        title: 'Descrição'.hardcoded,
        subtitle: workOrder.description,
        messageIfSubtitleIsNull: 'Sem descrição'.hardcoded,
        icon: const PlatformIcon(
          materialIcon: Icons.description_outlined,
          cupertinoIcon: CupertinoIcons.doc_text,
        ),
      ),
      if (user != null)
        TitleAndSubtitle(
          title: 'Responsável'.hardcoded,
          subtitle: user.name,
          icon: const PlatformIcon(
            materialIcon: Icons.person_outline,
            cupertinoIcon: CupertinoIcons.person,
          ),
        ),
      if (location != null)
        TitleAndSubtitle(
          title: 'Local'.hardcoded,
          subtitle: location.name,
          messageIfSubtitleIsNull: 'Sem local definido'.hardcoded,
          icon: const PlatformIcon(
            materialIcon: Icons.location_on_outlined,
            cupertinoIcon: CupertinoIcons.location,
          ),
        ),
      if (asset != null)
        TitleAndSubtitle(
          title: 'Equipamento'.hardcoded,
          subtitle: asset.name,
          messageIfSubtitleIsNull: 'Sem equipamento definido'.hardcoded,
          icon: const PlatformIcon(
            materialIcon: Icons.build_outlined,
            cupertinoIcon: CupertinoIcons.gear,
          ),
        ),
      Row(
        children: [
          Expanded(
            child: TitleAndSubtitle(
              title: 'Tipo'.hardcoded,
              subtitle: workOrder.type.label,
              backgroundColor: workOrder.type.color.withValues(alpha: 0.15),
              subtitleColor: workOrder.type.color,
              icon: const PlatformIcon(
                materialIcon: Icons.category_outlined,
                cupertinoIcon: CupertinoIcons.tag,
              ),
            ),
          ),
          gapW8,
          Expanded(
            child: TitleAndSubtitle(
              title: 'Prioridade'.hardcoded,
              subtitle: workOrder.priority.label,
              backgroundColor: workOrder.priority.color.withValues(alpha: 0.15),
              subtitleColor: workOrder.priority.color,
              icon: const PlatformIcon(
                materialIcon: Icons.warning_amber_outlined,
                cupertinoIcon: CupertinoIcons.exclamationmark_triangle,
              ),
            ),
          ),
        ],
      ),
      TitleAndSubtitle(
        title: 'Status'.hardcoded,
        subtitle: workOrder.status.label,
        backgroundColor: workOrder.status.color.withValues(alpha: 0.15),
        subtitleColor: workOrder.status.color,
        icon: const PlatformIcon(
          materialIcon: Icons.info_outline,
          cupertinoIcon: CupertinoIcons.info,
        ),
      ),
      Row(
        children: [
          Expanded(
            child: TitleAndSubtitle(
              title: 'Duração estimada'.hardcoded,
              subtitle: workOrder.estimatedDuration == null
                  ? null
                  : '${workOrder.estimatedDuration} min',
              messageIfSubtitleIsNull: 'Sem duração estimada'.hardcoded,
              icon: const PlatformIcon(
                materialIcon: Icons.hourglass_empty_outlined,
                cupertinoIcon: CupertinoIcons.timer,
              ),
            ),
          ),
          gapW8,
          Expanded(
            child: TitleAndSubtitle(
              title: 'Data programada'.hardcoded,
              subtitle: workOrder.scheduledDate?.formatDate(),
              messageIfSubtitleIsNull:
                  'Sem data de término programada'.hardcoded,
              icon: const PlatformIcon(
                materialIcon: Icons.calendar_today_outlined,
                cupertinoIcon: CupertinoIcons.calendar,
              ),
            ),
          ),
        ],
      ),
    ];

    return ResponsiveListFlow(
      isSliver: true,
      itemCount: items.length,
      maxItemWidth: ScreenType.phone.maxWidth,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return items[index];
      },
    );
  }
}
