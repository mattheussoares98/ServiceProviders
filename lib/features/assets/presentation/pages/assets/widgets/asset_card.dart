import 'dart:async';

import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/features/assets/presentation/pages/assets/widgets/subtitle.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssetCard extends StatelessWidget {
  const AssetCard({
    super.key,
    required this.asset,
    required this.categories,
    required this.allAssets,
  });

  final AssetEntity asset;
  final List<CategoryEntity> categories;
  final List<AssetEntity> allAssets;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final CategoryEntity? category = categories.firstWhereOrNull(
      (e) => e.id == asset.categoryId,
    );

    final AssetEntity? parentAsset = allAssets.firstWhereOrNull(
      (e) => e.id == asset.parentAssetId,
    );
    return Card(
      child: ExpansionTile(
        title: Row(
          children: [Expanded(child: BaseText.titleMedium(asset.name))],
        ),
        subtitle: SubTitle(asset: asset),
        children: [
          Column(
            children: [
              if (category != null)
                _DetailRow(label: 'Categoria:'.hardcoded, value: category.name),
              if (parentAsset != null)
                _DetailRow(
                  label: 'Equipamento Pai:'.hardcoded,
                  value: parentAsset.name,
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
                  value: _formatDate(asset.installDate),
                ),
              if (asset.warrantyExpiration != null)
                _DetailRow(
                  label: 'Vencimento da garantia:'.hardcoded,
                  value: _formatDate(asset.warrantyExpiration),
                ),
              if (asset.revisionForecast != null)
                _DetailRow(
                  label: 'Previsão de revisão:'.hardcoded,
                  value: _formatDate(asset.revisionForecast),
                ),
              if (asset.notes != null && asset.notes!.isNotEmpty)
                _DetailRow(
                  label: 'Observações:'.hardcoded,
                  value: asset.notes!,
                ),
              BlocSelector<AssetsCubit, AssetsState, bool>(
                selector: (state) => state.deletingIds.contains(asset.id),
                builder: (context, isLoading) {
                  return BaseTextButton(
                    isLoading: isLoading,
                    onPressed: () async {
                      final confirmed = await showAlertDialog(
                        context: context,
                        title: 'Excluir equipamento'.hardcoded,
                        contentText:
                            'Tem certeza que deseja excluir este equipamento?'
                                .hardcoded,
                        cancelActionText: 'Cancelar'.hardcoded,
                        defaultActionText: 'Excluir'.hardcoded,
                      );
                      if (confirmed == true && context.mounted) {
                        unawaited(
                          context.read<AssetsCubit>().deleteAsset(asset.id),
                        );
                      }
                    },
                    text: 'Excluir equipamento'.hardcoded,
                    textColor: AppColors.error,
                  );
                },
              ),
            ],
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Sizes.p120,
            child: BaseText.bodyMedium(label, fontWeight: FontWeight.bold),
          ),
          gapW8,
          Expanded(child: BaseText.bodyMedium(value)),
        ],
      ),
    );
  }
}
