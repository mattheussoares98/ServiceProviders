import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/presentation/pages/assets/widgets/create_update_asset/extensions.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          Expanded(child: BaseText.bodySmall(subtitleParts)),
          gapW8,
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.end,
              runAlignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              runSpacing: Sizes.p4,
              spacing: Sizes.p8,
              children: [
                _Item(color: asset.status.color, label: asset.status.label),
                _Item(
                  color: asset.criticality.color,
                  label: asset.criticality.label,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.p8,
        vertical: Sizes.p4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Sizes.p8),
      ),
      child: BaseText.caption(label, color: color, fontWeight: FontWeight.bold),
    );
  }
}
