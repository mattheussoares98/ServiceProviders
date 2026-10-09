part of '../create_update_work_order_page.dart';

class _AssetsDropdown extends StatelessWidget {
  const _AssetsDropdown({
    required this.selectedAssetId,
    required this.selectedLocationId,
    this.selectedCustomerId,
    required this.selectedAreaId,
    required this.onChanged,
    required this.applyAssociatedAreaId,
    this.isServiceProviderOnly = false,
  });

  final String? selectedAssetId;
  final String? selectedLocationId;
  final String? selectedCustomerId;
  final String? selectedAreaId;
  final ValueChanged<String?>? onChanged;
  final ValueChanged<String?> applyAssociatedAreaId;
  final bool isServiceProviderOnly;

  @override
  Widget build(BuildContext context) {
    if (isServiceProviderOnly || selectedCustomerId != null) {
      return _CustomerAssetsDropdown(
        selectedAssetId: selectedAssetId,
        selectedCustomerId: selectedCustomerId,
        isServiceProviderOnly: isServiceProviderOnly,
        onChanged: onChanged,
      );
    }

    return _InternalAssetsDropdown(
      selectedAssetId: selectedAssetId,
      selectedLocationId: selectedLocationId,
      selectedAreaId: selectedAreaId,
      onChanged: onChanged,
      applyAssociatedAreaId: applyAssociatedAreaId,
    );
  }
}
