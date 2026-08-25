part of '../create_update_work_order_page.dart';

class _WorkOrderExternalChangeBanner extends StatelessWidget {
  const _WorkOrderExternalChangeBanner({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.p16),
      padding: const EdgeInsets.all(Sizes.p12),
      decoration: BoxDecoration(
        color: AppColors.iconContainer,
        borderRadius: BorderRadius.circular(Sizes.p8),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const PlatformIcon(
            materialIcon: Icons.warning_amber_rounded,
            cupertinoIcon: CupertinoIcons.exclamationmark_triangle,
            color: AppColors.warning,
            size: 24,
          ),
          const SizedBox(width: Sizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseText(
                  'Esta ordem de serviço foi alterada externamente.'.hardcoded,
                  color: AppColors.base,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: Sizes.p4),
                BaseText.bodySmall(
                  'Clique em recarregar para atualizar os campos.'.hardcoded,
                  color: AppColors.fade,
                ),
              ],
            ),
          ),
          const SizedBox(width: Sizes.p8),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.p12,
              vertical: Sizes.p8,
            ),
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(Sizes.p8),
            onPressed: onReload,
            child: BaseText(
              'Recarregar'.hardcoded,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
