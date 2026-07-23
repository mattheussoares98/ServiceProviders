import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/assets/widgets/edit_asset_button.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/assets/widgets/location_are_priority_and_criticity.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/title_and_subtitle.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class AssetCard extends StatelessWidget {
  const AssetCard({super.key, required this.asset, required this.allAssets});

  final AssetEntity asset;
  final List<AssetEntity> allAssets;

  @override
  Widget build(BuildContext context) {
    final category = context
        .read<CategoriesCubit>()
        .state
        .categories
        .firstWhereOrNull((e) => e.id == asset.categoryId);

    final AssetEntity? parentAsset = allAssets.firstWhereOrNull(
      (e) => e.id == asset.parentAssetId,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaseText.titleMedium(asset.name),
            LocationAreaPriorityAndCriticity(asset: asset),
            gapH8,
            TitleAndSubtitle(
              title: 'Categoria'.hardcoded,
              subtitle: category?.name,
            ),
            TitleAndSubtitle(
              title: 'Equipamento pai'.hardcoded,
              subtitle: parentAsset?.name,
            ),
            TitleAndSubtitle(
              title: 'Fabricante'.hardcoded,
              subtitle: asset.manufacturer,
            ),
            TitleAndSubtitle(title: 'Modelo'.hardcoded, subtitle: asset.model),
            TitleAndSubtitle(
              title: 'Número de série'.hardcoded,
              subtitle: asset.serialNumber,
            ),
            TitleAndSubtitle(
              title: 'Data de instalação'.hardcoded,
              subtitle: asset.installDate?.formatDate(DateFormatType.yMMMMd),
            ),
            TitleAndSubtitle(
              title: 'Vencimento da garantia'.hardcoded,
              subtitle: asset.warrantyExpiration?.formatDate(),
            ),
            TitleAndSubtitle(
              title: 'Previsão de revisão'.hardcoded,
              subtitle: asset.revisionForecast?.formatDate(
                DateFormatType.yMMMMd,
              ),
            ),
            TitleAndSubtitle(
              title: 'Observações'.hardcoded,
              subtitle: asset.notes,
            ),
            gapH16,
            Align(
              alignment: .centerEnd,
              child: EditAssetButton(asset: asset),
            ),
          ],
        ),
      ),
    );
  }
}
