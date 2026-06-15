import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_state_view.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      isScrollable: false,
      appBar: BaseAppBar(
        title: 'Locais'.hardcoded,
        leading: BaseIconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          platformIcon: const PlatformIcon(
            materialIcon: Icons.menu,
            cupertinoIcon: CupertinoIcons.bars,
          ),
        ),
      ),
      body: BlocProvider(
        create: (context) => GetIt.I<LocationsCubit>()..loadLocationsAndAreas(),
        child: Builder(
          builder: (context) {
            return BaseStateView<
              LocationsCubit,
              LocationsState,
              List<LocationEntity>
            >(
              dataSelector: (state) => state.locations,
              onRetry: context.read<LocationsCubit>().loadLocationsAndAreas,
              builder: (context, locations) {
                return ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final location = locations[index];
                    return ListTile(title: BaseText(location.name));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
