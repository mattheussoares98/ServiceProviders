import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/widgets/open_drawer_icon_button.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/locations/widgets/location_card.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_empty_state.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';

@RoutePage()
class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      onRefresh: context.read<LocationsCubit>().loadLocationsAndAreas,
      isScrollable: false,
      appBar: BaseAppBar(
        title: 'Locais'.hardcoded,
        leading: const OpenDrawerIconButton(),
        actions: [
          BlocSelector<LocationsCubit, LocationsState, bool>(
            selector: (state) => state.section(BaseSections.load).isError,
            builder: (context, hasError) {
              return BaseIconButton(
                permission: const ActionPermission.resource(
                  resourceType: ResourceType.locations,
                  permissionAction: PermissionAction.create,
                ),
                onPressed: hasError
                    ? null
                    : () => context
                          .read<LocationsCubit>()
                          .navigateToCreateUpdateLocation(),
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.add,
                  cupertinoIcon: CupertinoIcons.add,
                ),
              );
            },
          ),
        ],
      ),
      body:
          BaseStateView<
            LocationsCubit,
            LocationsState,
            (List<LocationEntity>, bool)
          >(
            dataSelector: (state) => (state.locations, state.hasLocations),
            onRetry: context.read<LocationsCubit>().loadLocationsAndAreas,
            builder: (context, data) {
              final locations = data.$1;
              final hasLocations = data.$2;
              final hasLocationCreate = context.select<UsersCubit, bool>(
                (c) => c.hasPermission(
                  const ActionPermission.resource(
                    resourceType: ResourceType.locations,
                    permissionAction: PermissionAction.create,
                  ),
                ),
              );
              final workType = context.select<CompanyCubit, WorkType>(
                (c) => c.state.company?.workType ?? WorkType.hybrid,
              );
              final bool needsLocation =
                  workType.requiresLocation && !hasLocations;
              if (needsLocation) {
                return BaseEmptyState(
                  title: 'Cadastrar local'.hardcoded,
                  description:
                      'Cadastre um local para poder vincular seus equipamentos'
                          .hardcoded,
                  actionLabel: 'Cadastrar Local'.hardcoded,
                  canPerformAction: hasLocationCreate,
                  onAction: () => context
                      .read<LocationsCubit>()
                      .navigateToCreateUpdateLocation(),
                  icon: const PlatformIcon(
                    materialIcon: Icons.location_on_rounded,
                    cupertinoIcon: CupertinoIcons.location_solid,
                  ),
                );
              }

              final state = context.watch<LocationsCubit>().state;
              if (locations.isEmpty) {
                return BaseEmptyState.text(
                  title: 'Nenhum local cadastrado'.hardcoded,
                );
              }

              locations.sort((a, b) => a.name.compareTo(b.name));
              return ResponsiveListFlow(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return LocationCard(
                    location: location,
                    areas: state.areasByLocation[location.id] ?? const [],
                  );
                },
              );
            },
          ),
    );
  }
}
