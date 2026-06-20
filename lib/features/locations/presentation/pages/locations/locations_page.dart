import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/create_location.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/location_card/location_card.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_state_view.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/show_modal_page.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        leading: BaseIconButton(
          onPressed: Scaffold.of(context).openDrawer,
          platformIcon: const PlatformIcon(
            materialIcon: Icons.menu,
            cupertinoIcon: CupertinoIcons.bars,
          ),
        ),
        actions: [
          BaseIconButton(
            onPressed: () => showModalPage<void>(
              BlocProvider.value(
                value: context.read<LocationsCubit>(),
                child: const CreateLocation(),
              ),
              context,
            ),
            platformIcon: const PlatformIcon(
              materialIcon: Icons.add,
              cupertinoIcon: CupertinoIcons.add,
            ),
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

          return ListView.builder(
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
