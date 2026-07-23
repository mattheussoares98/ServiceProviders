import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/extensions.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_indication_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class SubTitle extends StatelessWidget {
  const SubTitle({super.key, required this.asset});

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    //TODO should confirm what happens when there are no allAreas in LocationsCubit
    final AreaEntity? area = context.select<LocationsCubit, AreaEntity?>(
      (cubit) =>
          cubit.state.allAreas.firstWhereOrNull((e) => e.id == asset.areaId),
    );
    final LocationEntity? location = context
        .select<LocationsCubit, LocationEntity?>(
          (cubit) => cubit.state.locations.firstWhereOrNull(
            (e) => e.id == area?.locationId,
          ),
        );

    final locationInfo = [area?.name, location?.name].join(' - ');
    final subtitleParts = [
      if (asset.code?.isNotEmpty ?? false) '[${asset.code}]',
      if (locationInfo.isNotEmpty) locationInfo,
    ].join(' ');

    return Padding(
      padding: const EdgeInsets.only(top: Sizes.p4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(flex: 2, child: BaseText.bodyMedium(subtitleParts)),
          gapW8,
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: BaseIndicationItem(
                      color: asset.status.color,
                      label: asset.status.label,
                    ),
                  ),
                  WidgetSpan(
                    child: BaseIndicationItem(
                      color: asset.criticality.color,
                      label: asset.criticality.label,
                    ),
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
