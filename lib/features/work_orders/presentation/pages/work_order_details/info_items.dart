import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/sla_policies/presentation/cubits/sla_policies/sla_policies_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/title_and_subtitle.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
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
    final area = context.select<LocationsCubit, AreaEntity?>(
      (cubit) => cubit.state.allAreas.firstWhereOrNull(
        (e) => e.id == workOrder.areaId,
      ),
    );
    final asset = context.select<AssetsCubit, AssetEntity?>(
      (cubit) =>
          cubit.state.assets.firstWhereOrNull((e) => e.id == workOrder.assetId),
    );
    final slaPolicy = context.select<SlaPoliciesCubit, SlaPolicyEntity?>(
      (cubit) => cubit.state.slaPolicies.firstWhereOrNull(
        (e) => e.id == workOrder.slaPolicyId,
      ),
    );

    final spCompanyId = workOrder.serviceProviderCompanyId;
    final serviceProviderProfile = spCompanyId == null
        ? null
        : context.select<ServiceProvidersCubit, ServiceProviderProfileEntity?>(
            (cubit) => cubit.state.profiles[spCompanyId]?.firstWhereOrNull(
              (p) => p.id == workOrder.providerProfileId,
            ),
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
      if (spCompanyId != null)
        BaseStateView<
          ServiceProvidersCubit,
          ServiceProvidersState,
          ServiceProviderCompanyEntity?
        >(
          dataSelector: (state) {
            return state.companies.firstWhereOrNull((e) => e.id == spCompanyId);
          },
          builder: (context, serviceProviderCompany) {
            if (serviceProviderCompany == null) {
              return const SizedBox.shrink();
            }
            return TitleAndSubtitle(
              backgroundColor: context.theme.secondaryHeaderColor.withAlpha(
                100,
              ),
              title: 'Empresa prestadora do serviço'.hardcoded,
              subtitle: serviceProviderCompany.name,
              icon: const PlatformIcon(
                materialIcon: Icons.business,
                cupertinoIcon: CupertinoIcons.building_2_fill,
              ),
            );
          },
        ),
      if (serviceProviderProfile != null)
        TitleAndSubtitle(
          backgroundColor: context.theme.secondaryHeaderColor.withAlpha(100),
          title: 'Responsável da empresa prestadora'.hardcoded,
          subtitle: serviceProviderProfile.name,
          icon: const PlatformIcon(
            materialIcon: Icons.person_pin_outlined,
            cupertinoIcon: CupertinoIcons.person_badge_plus,
          ),
        ),
      if (location != null)
        TitleAndSubtitle(
          title: 'Local'.hardcoded,
          subtitle: location.name,
          messageIfSubtitleIsNull: 'Sem local definido'.hardcoded,
          icon: const PlatformIcon(
            materialIcon: Icons.location_city,
            cupertinoIcon: CupertinoIcons.location,
          ),
        ),
      if (area != null)
        TitleAndSubtitle(
          title: 'Área'.hardcoded,
          subtitle: area.name,
          messageIfSubtitleIsNull: 'Sem área definida'.hardcoded,
          icon: const PlatformIcon(
            materialIcon: Icons.location_on,
            cupertinoIcon: CupertinoIcons.location_solid,
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
      if (workOrder.slaPolicyId != null)
        TitleAndSubtitle(
          title: 'Política de SLA'.hardcoded,
          subtitle: slaPolicy != null
              ? '${slaPolicy.name} (${slaPolicy.targetHours}h)'
              : null,
          messageIfSubtitleIsNull: 'Sem SLA'.hardcoded,
          icon: const PlatformIcon(
            materialIcon: Icons.timer_outlined,
            cupertinoIcon: CupertinoIcons.clock,
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
