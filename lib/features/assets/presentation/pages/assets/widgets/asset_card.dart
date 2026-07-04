import 'package:clean_architecture/core/utils/extensions/date_time_extension.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/presentation/pages/assets/widgets/edit_asset_button.dart';
import 'package:clean_architecture/features/assets/presentation/pages/assets/widgets/subtitle.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AssetCard extends StatelessWidget {
  const AssetCard({super.key, required this.asset, required this.allAssets});

  final AssetEntity asset;
  final List<AssetEntity> allAssets;

  @override
  Widget build(BuildContext context) {
    //TODO use the CategoriesCubit instead
    const CategoryEntity? category = null; /*  categories.firstWhereOrNull(
      (e) => e.id == asset.categoryId,
    ); */

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
            SubTitle(asset: asset),
            if (category != null)
              _DetailRow(label: 'Categoria:'.hardcoded, value: category.name),
            if (parentAsset?.name.isNotEmpty ?? false)
              _DetailRow(
                label: 'Equipamento Pai:'.hardcoded,
                value: parentAsset!.name,
              ),
            if (asset.manufacturer != null && asset.manufacturer!.isNotEmpty)
              _DetailRow(
                label: 'Fabricante:'.hardcoded,
                value: asset.manufacturer!,
              ),
            if (asset.model != null && asset.model!.isNotEmpty)
              _DetailRow(label: 'Modelo:'.hardcoded, value: asset.model!),
            if (asset.serialNumber != null && asset.serialNumber!.isNotEmpty)
              _DetailRow(
                label: 'Número de série:'.hardcoded,
                value: asset.serialNumber!,
              ),
            if (asset.installDate != null)
              _DetailRow(
                label: 'Data de instalação:'.hardcoded,
                value: asset.installDate!.formatDate(DateFormatType.yMMMMd),
              ),
            if (asset.warrantyExpiration != null)
              _DetailRow(
                label: 'Vencimento da garantia:'.hardcoded,
                value: asset.warrantyExpiration!.formatDate(),
              ),
            if (asset.revisionForecast != null)
              _DetailRow(
                label: 'Previsão de revisão:'.hardcoded,
                value: asset.revisionForecast!.formatDate(
                  DateFormatType.yMMMMd,
                ),
              ),
            if (asset.notes != null && asset.notes!.isNotEmpty)
              _DetailRow(label: 'Observações:'.hardcoded, value: asset.notes!),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: context.theme.textTheme.bodyMedium,
        children: [TextSpan(text: value)],
      ),
    );
  }
}
