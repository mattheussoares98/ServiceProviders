import 'dart:async';

import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_criticality.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_status.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
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
    required this.locations,
    required this.areas,
    required this.categories,
    required this.allAssets,
  });

  final AssetEntity asset;
  final List<LocationEntity> locations;
  final List<AreaEntity> areas;
  final List<CategoryEntity> categories;
  final List<AssetEntity> allAssets;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final AreaEntity? area = areas.firstWhereOrNull(
      (e) => e.id == asset.areaId,
    );

    final LocationEntity? location = locations.firstWhereOrNull(
      (e) => e.id == area?.locationId,
    );

    final CategoryEntity? category = categories.firstWhereOrNull(
      (e) => e.id == asset.categoryId,
    );

    final AssetEntity? parentAsset = allAssets.firstWhereOrNull(
      (e) => e.id == asset.parentAssetId,
    );

    final locationInfo = [area?.name, location?.name].join(' - ');

    final subtitleParts = [
      if (asset.code?.isNotEmpty ?? false) '[${asset.code}]',
      if (locationInfo.isNotEmpty) locationInfo,
    ].join(' ');

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: BaseText.titleMedium(asset.name)),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.p8,
                vertical: Sizes.p4,
              ),
              decoration: BoxDecoration(
                color: asset.status.color(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Sizes.p8),
              ),
              child: BaseText.caption(
                asset.status.label,
                color: asset.status.color(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            gapW8,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.p8,
                vertical: Sizes.p4,
              ),
              decoration: BoxDecoration(
                color: asset.criticality.color(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Sizes.p8),
              ),
              child: BaseText.caption(
                asset.criticality.label,
                color: asset.criticality.color(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: subtitleParts.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: Sizes.p4),
                child: BaseText.bodySmall(subtitleParts),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (category != null)
                  _DetailRow(
                    label: 'Categoria:'.hardcoded,
                    value: category.name,
                  ),
                if (parentAsset != null)
                  _DetailRow(
                    label: 'Equipamento Pai:'.hardcoded,
                    value: parentAsset.name,
                  ),
                if (asset.manufacturer != null &&
                    asset.manufacturer!.isNotEmpty)
                  _DetailRow(
                    label: 'Fabricante:'.hardcoded,
                    value: asset.manufacturer!,
                  ),
                if (asset.model != null && asset.model!.isNotEmpty)
                  _DetailRow(label: 'Modelo:'.hardcoded, value: asset.model!),
                if (asset.serialNumber != null &&
                    asset.serialNumber!.isNotEmpty)
                  _DetailRow(
                    label: 'Número de Série:'.hardcoded,
                    value: asset.serialNumber!,
                  ),
                if (asset.installDate != null)
                  _DetailRow(
                    label: 'Data de Instalação:'.hardcoded,
                    value: _formatDate(asset.installDate),
                  ),
                if (asset.warrantyExpiration != null)
                  _DetailRow(
                    label: 'Vencimento Garantia:'.hardcoded,
                    value: _formatDate(asset.warrantyExpiration),
                  ),
                if (asset.revisionForecast != null)
                  _DetailRow(
                    label: 'Previsão de Revisão:'.hardcoded,
                    value: _formatDate(asset.revisionForecast),
                  ),
                if (asset.notes != null && asset.notes!.isNotEmpty)
                  _DetailRow(
                    label: 'Observações:'.hardcoded,
                    value: asset.notes!,
                  ),
                gapH16,
                Align(
                  alignment: Alignment.centerRight,
                  child: BaseTextButton(
                    onPressed: () async {
                      final confirmed = await showAlertDialog(
                        context: context,
                        title: 'Excluir Equipamento'.hardcoded,
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
                    text: 'Excluir Equipamento'.hardcoded,
                    textColor: AppColors.error,
                  ),
                ),
              ],
            ),
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

extension AssetStatusX on AssetStatus {
  String get label {
    switch (this) {
      case AssetStatus.active:
        return 'Ativo';
      case AssetStatus.inactive:
        return 'Inativo';
      case AssetStatus.decommissioned:
        return 'Desativado';
    }
  }

  Color color(BuildContext context) {
    switch (this) {
      case AssetStatus.active:
        return AppColors.success;
      case AssetStatus.inactive:
        return AppColors.warning;
      case AssetStatus.decommissioned:
        return AppColors.error;
    }
  }
}

extension AssetCriticalityX on AssetCriticality {
  String get label {
    switch (this) {
      case AssetCriticality.low:
        return 'Baixa';
      case AssetCriticality.medium:
        return 'Média';
      case AssetCriticality.high:
        return 'Alta';
      case AssetCriticality.missionCritical:
        return 'Crítica';
    }
  }

  Color color(BuildContext context) {
    switch (this) {
      case AssetCriticality.low:
        return AppColors.green500;
      case AssetCriticality.medium:
        return AppColors.warning;
      case AssetCriticality.high:
        return Colors.orange;
      case AssetCriticality.missionCritical:
        return AppColors.error;
    }
  }
}
