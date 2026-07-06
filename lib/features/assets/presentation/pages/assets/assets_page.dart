import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/assets/widgets/asset_card.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/assets/widgets/create_asset_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

@RoutePage()
class AssetsPage extends HookWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO read all this page code to check possible improvements

    useEffect(() {
      context.read<AssetsCubit>().loadAssets();
      return null;
    }, []);

    return BaseScaffold(
      isScrollable: false,
      onRefresh: context.read<AssetsCubit>().loadAssets,
      appBar: BaseAppBar(
        title: 'Equipamentos'.hardcoded,
        leading: BaseIconButton(
          onPressed: Scaffold.of(context).openDrawer,
          platformIcon: const PlatformIcon(
            materialIcon: Icons.menu,
            cupertinoIcon: CupertinoIcons.bars,
          ),
        ),
        actions: const [CreateAssetButton()],
      ),
      body: BaseStateView<AssetsCubit, AssetsState, List<AssetEntity>>(
        dataSelector: (state) => state.assets,
        onRetry: context.read<AssetsCubit>().loadAssets,
        builder: (context, assets) {
          if (assets.isEmpty) {
            return BaseText.error('Nenhum equipamento cadastrado'.hardcoded);
          }

          assets.sort((a, b) => a.name.compareTo(b.name));
          return ResponsiveListFlow(
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              return AssetCard(asset: asset, allAssets: assets);
            },
          );
        },
      ),
    );
  }
}
