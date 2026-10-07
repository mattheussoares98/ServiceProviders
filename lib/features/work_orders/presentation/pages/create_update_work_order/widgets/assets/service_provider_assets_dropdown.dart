part of '../../create_update_work_order_page.dart';

class _ServiceProviderAssetsDropdown extends StatelessWidget {
  const _ServiceProviderAssetsDropdown({
    required this.selectedAssetId,
    required this.selectedCustomerId,
    required this.onChanged,
  });

  final String? selectedAssetId;
  final String? selectedCustomerId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final allAssets = context.select<AssetsCubit, List<AssetEntity>>(
      (cubit) => cubit.state.assets,
    );

    final selectedAsset = allAssets.firstWhereOrNull(
      (a) => a.id == selectedAssetId,
    );

    final relevantAssets = selectedCustomerId != null
        ? allAssets
              .where(
                (a) =>
                    a.customerId == selectedCustomerId || a.customerId == null,
              )
              .toList()
        : allAssets.where((a) => a.customerId == null).toList();

    final String hintText;
    if (allAssets.isEmpty) {
      hintText = 'Sem equipamentos cadastrados'.hardcoded;
    } else if (selectedCustomerId != null) {
      hintText = relevantAssets.isEmpty
          ? 'Nenhum equipamento para este cliente'.hardcoded
          : 'Selecionar equipamento'.hardcoded;
    } else {
      hintText = relevantAssets.isEmpty
          ? 'Selecione um cliente para ver equipamentos'.hardcoded
          : 'Equipamento geral ou selecione cliente'.hardcoded;
    }

    final hasSelection = selectedAsset != null;
    final canInteract =
        onChanged != null && allAssets.isNotEmpty && relevantAssets.isNotEmpty;

    return Container(
      key: const ValueKey('Asset'),
      height: 48,
      decoration: BoxDecoration(
        color: context.theme.disabledColor.withValues(alpha: 50 / 255),
        borderRadius: BorderRadius.circular(Sizes.p8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Sizes.p8),
        onTap: canInteract
            ? () async {
                FocusManager.instance.primaryFocus?.unfocus();
                final result = await SearchableAssetPickerModal.show(
                  context,
                  assets: relevantAssets,
                  selectedAssetId: selectedAssetId,
                  selectedCustomerId: selectedCustomerId,
                );
                if (result != null && onChanged != null) {
                  if (result.isClear) {
                    onChanged!(null);
                  } else if (result.asset != null) {
                    onChanged!(result.asset!.id);
                  }
                }
              }
            : null,
        child: Stack(
          children: [
            if (hasSelection)
              Positioned(
                left: Sizes.p8,
                top: Sizes.p4,
                child: BaseText.caption(
                  'Equipamento (opcional)'.hardcoded,
                  color: AppColors.fade,
                ),
              ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                  left: Sizes.p12,
                  right: Sizes.p40,
                  top: hasSelection ? Sizes.p12 : 0,
                ),
                child: Align(
                  child: BaseText(
                    hasSelection ? selectedAsset.name : hintText,
                    color: hasSelection ? null : AppColors.fade,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              right: Sizes.p8,
              top: 0,
              bottom: 0,
              child: Center(
                child: hasSelection && onChanged != null
                    ? BaseIconButton(
                        key: const ValueKey('AssetClearButton'),
                        platformIcon: const PlatformIcon(
                          materialIcon: Icons.clear,
                          cupertinoIcon: CupertinoIcons.clear_circled_solid,
                          color: Colors.red,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => onChanged!(null),
                      )
                    : const PlatformIcon(
                        materialIcon: Icons.search,
                        cupertinoIcon: CupertinoIcons.search,
                        color: AppColors.fade,
                        size: 18,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
