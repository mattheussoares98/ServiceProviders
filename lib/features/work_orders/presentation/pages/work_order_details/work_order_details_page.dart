import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachments.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/title_and_subtitle.dart';

@RoutePage()
class WorkOrderDetailsPage extends StatelessWidget {
  const WorkOrderDetailsPage({super.key, required this.workOrder});

  final WorkOrderEntity workOrder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<AttachmentsCubit>()..init(workOrder.id),
      child: _WorkOrderDetails(workOrder: workOrder),
    );
  }
}

class _WorkOrderDetails extends StatelessWidget {
  const _WorkOrderDetails({required this.workOrder});

  final WorkOrderEntity workOrder;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      isScrollable: false,
      appBar: BaseAppBar(title: 'Detalhes da ordem de serviço'.hardcoded),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TitleAndSubtitle(
              title: 'Título'.hardcoded,
              subtitle: workOrder.title,
            ),
          ),
          SliverToBoxAdapter(
            child: TitleAndSubtitle(
              title: 'Descrição',
              subtitle: workOrder.description,
              messageIfSubtitleIsNull: 'Sem descrição'.hardcoded,
            ),
          ),
          BlocSelector<UsersCubit, UsersState, UserProfileEntity?>(
            selector: (state) => state.users.firstWhereOrNull(
              (e) => e.id == workOrder.assignedToId,
            ),
            builder: (context, user) {
              if (user == null) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    TitleAndSubtitle(title: 'Responsável', subtitle: user.name),
                  ],
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: TitleAndSubtitle(
              title: 'Tipo'.hardcoded,
              subtitle: workOrder.type.label,
            ),
          ),
          SliverToBoxAdapter(
            child: TitleAndSubtitle(
              title: 'Prioridade'.hardcoded,
              subtitle: workOrder.priority.label,
            ),
          ),
          SliverToBoxAdapter(
            child: TitleAndSubtitle(
              title: 'Status'.hardcoded,
              subtitle: workOrder.status.label,
            ),
          ),
          BlocSelector<LocationsCubit, LocationsState, LocationEntity?>(
            selector: (state) => state.locations.firstWhereOrNull(
              (e) => e.id == workOrder.locationId,
            ),
            builder: (context, location) {
              if (location == null) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    TitleAndSubtitle(
                      title: 'Local'.hardcoded,
                      subtitle: location.name,
                      messageIfSubtitleIsNull: 'Sem local definido'.hardcoded,
                    ),
                  ],
                ),
              );
            },
          ),
          BlocSelector<AssetsCubit, AssetsState, AssetEntity?>(
            selector: (state) =>
                state.assets.firstWhereOrNull((e) => e.id == workOrder.assetId),
            builder: (context, asset) {
              if (asset == null) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    TitleAndSubtitle(
                      title: 'Equipamento'.hardcoded,
                      subtitle: asset.name,
                      messageIfSubtitleIsNull:
                          'Sem equipamento definido'.hardcoded,
                    ),
                  ],
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: TitleAndSubtitle(
              title: 'Duração estimada'.hardcoded,
              subtitle: '${workOrder.estimatedDuration} min',
              messageIfSubtitleIsNull: 'Sem duração estimada'.hardcoded,
            ),
          ),
          SliverToBoxAdapter(
            child: TitleAndSubtitle(
              title: 'Data programada'.hardcoded,
              subtitle: workOrder.scheduledDate?.formatDate(),
              messageIfSubtitleIsNull:
                  'Sem data de término programada'.hardcoded,
            ),
          ),
          Attachments(workOrderId: workOrder.id),
        ],
      ),
    );
  }
}
