part of '../create_update_work_order_page.dart';

class _TryAgainButton extends StatelessWidget {
  const _TryAgainButton({
    required this.assetsError,
    required this.locationsError,
    required this.usersError,
  });

  final String? assetsError;
  final String? locationsError;
  final String? usersError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          children: [
            BaseText.error(
              '${assetsError ?? ''}\n${locationsError ?? ''}\n${usersError ?? ''}',
            ),
            gapH32,
            BaseButton(
              onTap: () async {
                await Future.wait([
                  if (assetsError?.isNotEmpty == true)
                    context.read<AssetsCubit>().loadAssets(),
                  if (locationsError?.isNotEmpty == true)
                    context.read<LocationsCubit>().loadLocationsAndAreas(),
                  if (usersError?.isNotEmpty == true)
                    context.read<UsersCubit>().loadUsers(),
                ]);
              },
              text: 'Tentar novamente'.hardcoded,
            ),
          ],
        ),
      ),
    );
  }
}
