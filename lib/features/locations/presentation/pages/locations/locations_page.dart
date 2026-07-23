import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/widgets/open_drawer_icon_button.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/locations/widgets/location_card.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

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
            selector: (state) => state.errorMessage?.isNotEmpty ?? false,
            builder: (context, hasError) {
              return BaseIconButton(
                permission: const ActionPermission(
                  resource: ResourceType.locations,
                  action: PermissionAction.create,
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
      body: BaseStateView<LocationsCubit, LocationsState, List<LocationEntity>>(
        dataSelector: (state) => state.locations,
        onRetry: context.read<LocationsCubit>().loadLocationsAndAreas,
        builder: (context, locations) {
          final state = context.watch<LocationsCubit>().state;
          if (locations.isEmpty) {
            return BaseText.error('Nenhum local cadastrado'.hardcoded);
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
