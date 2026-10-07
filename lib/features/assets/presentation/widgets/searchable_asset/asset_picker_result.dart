part of 'searchable_asset_picker_modal.dart';

class AssetPickerResult {
  const AssetPickerResult.selected(this.asset) : isClear = false;
  const AssetPickerResult.cleared() : asset = null, isClear = true;

  final AssetEntity? asset;
  final bool isClear;
}
