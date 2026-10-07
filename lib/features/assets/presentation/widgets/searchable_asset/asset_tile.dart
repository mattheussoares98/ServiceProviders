part of 'searchable_asset_picker_modal.dart';

class _AssetTile extends StatelessWidget {
  const _AssetTile({
    required this.asset,
    required this.isSelected,
    required this.onTap,
  });

  final AssetEntity asset;
  final bool isSelected;
  final VoidCallback onTap;

  String? _buildSubtitle() {
    final buffer = StringBuffer();
    void writePart(String text) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      buffer.write(text);
    }

    final code = asset.code?.trim();
    if (code != null && code.isNotEmpty) {
      writePart('Cód: $code');
    }
    final manufacturer = asset.manufacturer?.trim();
    if (manufacturer != null && manufacturer.isNotEmpty) {
      writePart(manufacturer);
    }
    final model = asset.model?.trim();
    if (model != null && model.isNotEmpty) {
      writePart(model);
    }
    final serialNumber = asset.serialNumber?.trim();
    if (serialNumber != null && serialNumber.isNotEmpty) {
      writePart('S/N: $serialNumber');
    }

    return buffer.isEmpty ? null : buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _buildSubtitle();

    return Padding(
      key: ValueKey('AssetTile_${asset.id}'),
      padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
      child: BaseListTile(
        title: asset.name,
        subtitle: subtitle,
        platformIcon: PlatformIcon(
          materialIcon: asset.customerId != null
              ? Icons.precision_manufacturing_outlined
              : Icons.category_outlined,
          cupertinoIcon: asset.customerId != null
              ? CupertinoIcons.cube_box
              : CupertinoIcons.square_grid_2x2,
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.onSurface,
        ),
        tileColor: isSelected
            ? context.colorScheme.primary.withValues(alpha: 0.08)
            : null,
        borderRadius: BorderRadius.circular(Sizes.p8),
        trailing: isSelected
            ? PlatformIcon(
                materialIcon: Icons.check_circle,
                cupertinoIcon: CupertinoIcons.checkmark_circle_fill,
                color: context.colorScheme.primary,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
