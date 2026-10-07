import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

part 'asset_picker_result.dart';
part 'asset_tile.dart';
part 'section_header.dart';

class SearchableAssetPickerModal extends HookWidget {
  const SearchableAssetPickerModal({
    super.key,
    required this.assets,
    this.selectedAssetId,
    this.selectedCustomerId,
    this.onSelected,
  });

  final List<AssetEntity> assets;
  final String? selectedAssetId;
  final String? selectedCustomerId;
  final ValueChanged<AssetEntity?>? onSelected;

  static Future<AssetPickerResult?> show(
    BuildContext context, {
    required List<AssetEntity> assets,
    String? selectedAssetId,
    String? selectedCustomerId,
    ValueChanged<AssetEntity?>? onSelected,
  }) async {
    return await showModalPage<AssetPickerResult>(
      SearchableAssetPickerModal(
        assets: assets,
        selectedAssetId: selectedAssetId,
        selectedCustomerId: selectedCustomerId,
        onSelected: onSelected,
      ),
      context,
    );
  }

  bool _matchesQuery(AssetEntity asset, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase().trim();
    final nameMatch = asset.name.toLowerCase().contains(q);
    final codeMatch = asset.code?.toLowerCase().contains(q) ?? false;
    final modelMatch = asset.model?.toLowerCase().contains(q) ?? false;
    final manufacturerMatch =
        asset.manufacturer?.toLowerCase().contains(q) ?? false;
    return nameMatch || codeMatch || modelMatch || manufacturerMatch;
  }

  void _selectAsset(BuildContext context, AssetEntity asset) {
    onSelected?.call(asset);
    Navigator.of(context).pop(AssetPickerResult.selected(asset));
  }

  void _clearSelection(BuildContext context) {
    onSelected?.call(null);
    Navigator.of(context).pop(const AssetPickerResult.cleared());
  }

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final query = searchQuery.value.trim();

    final filteredAssets = useMemoized(() {
      return assets.where((a) => _matchesQuery(a, query)).toList();
    }, [assets, query]);

    final customerAssets = useMemoized(() {
      if (selectedCustomerId == null) return <AssetEntity>[];
      return filteredAssets
          .where((a) => a.customerId == selectedCustomerId)
          .toList();
    }, [filteredAssets, selectedCustomerId]);

    final genericAssets = useMemoized(() {
      return filteredAssets.where((a) => a.customerId == null).toList();
    }, [filteredAssets]);

    final otherAssets = useMemoized(() {
      if (selectedCustomerId == null) {
        return filteredAssets.where((a) => a.customerId != null).toList();
      }
      return <AssetEntity>[];
    }, [filteredAssets, selectedCustomerId]);

    final isSearching = query.isNotEmpty;
    final hasCustomerSection =
        selectedCustomerId != null &&
        (!isSearching || customerAssets.isNotEmpty);
    final hasGenericSection = !isSearching || genericAssets.isNotEmpty;
    final hasOtherSection =
        selectedCustomerId == null && otherAssets.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: Sizes.p16,
        right: Sizes.p16,
        top: Sizes.p16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Sizes.p16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: BaseText.headline('Selecionar equipamento'.hardcoded),
              ),
              BaseButton.text(
                key: const ValueKey('SearchableAssetPickerClearButton'),
                onPressed: selectedAssetId != null
                    ? () => _clearSelection(context)
                    : null,
                text: 'Limpar'.hardcoded,
              ),
            ],
          ),
          gapH12,
          BaseTextFormField(
            key: const ValueKey('SearchableAssetPickerSearchField'),
            controller: searchController,
            hintText: 'Buscar por nome, código, modelo...'.hardcoded,
            prefixIcon: const PlatformIcon(
              materialIcon: Icons.search,
              cupertinoIcon: CupertinoIcons.search,
            ),
            suffixIcon: query.isNotEmpty
                ? BaseIconButton(
                    onPressed: searchController.clear,
                    platformIcon: const PlatformIcon(
                      materialIcon: Icons.clear,
                      cupertinoIcon: CupertinoIcons.clear_circled,
                    ),
                  )
                : null,
          ),
          gapH8,
          if (filteredAssets.isEmpty)
            Expanded(
              child: Center(
                key: const ValueKey('SearchableAssetPickerEmptyState'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PlatformIcon(
                      materialIcon: Icons.search_off,
                      cupertinoIcon: CupertinoIcons.search,
                      color: AppColors.fade,
                    ),
                    gapH12,
                    BaseText(
                      assets.isEmpty
                          ? 'Nenhum equipamento cadastrado'.hardcoded
                          : 'Nenhum equipamento encontrado'.hardcoded,
                      color: AppColors.fade,
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: CustomScrollView(
                slivers: [
                  if (hasCustomerSection) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Equipamentos do Cliente'.hardcoded,
                        count: customerAssets.length,
                      ),
                    ),
                    if (customerAssets.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.p12,
                          ),
                          child: BaseText.bodySmall(
                            'Nenhum equipamento específico para este cliente'
                                .hardcoded,
                            color: AppColors.fade,
                          ),
                        ),
                      )
                    else
                      SliverList.builder(
                        itemCount: customerAssets.length,
                        itemBuilder: (context, index) {
                          final asset = customerAssets[index];
                          return _AssetTile(
                            asset: asset,
                            isSelected: asset.id == selectedAssetId,
                            onTap: () => _selectAsset(context, asset),
                          );
                        },
                      ),
                  ],
                  if (hasGenericSection) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Equipamentos Gerais'.hardcoded,
                        count: genericAssets.length,
                      ),
                    ),
                    if (genericAssets.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.p12,
                          ),
                          child: BaseText.bodySmall(
                            'Nenhum equipamento geral disponível'.hardcoded,
                            color: AppColors.fade,
                          ),
                        ),
                      )
                    else
                      SliverList.builder(
                        itemCount: genericAssets.length,
                        itemBuilder: (context, index) {
                          final asset = genericAssets[index];
                          return _AssetTile(
                            asset: asset,
                            isSelected: asset.id == selectedAssetId,
                            onTap: () => _selectAsset(context, asset),
                          );
                        },
                      ),
                  ],
                  if (hasOtherSection) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Outros Equipamentos'.hardcoded,
                        count: otherAssets.length,
                      ),
                    ),
                    SliverList.builder(
                      itemCount: otherAssets.length,
                      itemBuilder: (context, index) {
                        final asset = otherAssets[index];
                        return _AssetTile(
                          asset: asset,
                          isSelected: asset.id == selectedAssetId,
                          onTap: () => _selectAsset(context, asset),
                        );
                      },
                    ),
                  ],
                  const SliverToBoxAdapter(child: gapH24),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
