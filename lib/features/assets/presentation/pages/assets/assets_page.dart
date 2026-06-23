import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/features/assets/presentation/pages/assets/widgets/asset_card.dart';
import 'package:clean_architecture/features/assets/presentation/pages/assets/widgets/create_update_asset/create_update_asset_dialog.dart';
import 'package:clean_architecture/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_state_view.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/show_modal_page.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
        actions: [
          BaseIconButton(
            onPressed: () {
              showModalPage<void>(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<AssetsCubit>()),
                    BlocProvider.value(value: context.read<LocationsCubit>()),
                    BlocProvider.value(value: context.read<CategoriesCubit>()),
                  ],
                  child: const CreateAssetDialog(),
                ),
                context,
              );
            },
            platformIcon: const PlatformIcon(
              materialIcon: Icons.add,
              cupertinoIcon: CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body: BaseStateView<AssetsCubit, AssetsState, List<AssetEntity>>(
        dataSelector: (state) => state.assets,
        onRetry: context.read<AssetsCubit>().loadAssets,
        builder: (context, assets) {
          if (assets.isEmpty) {
            return BaseText.error('Nenhum equipamento cadastrado'.hardcoded);
          }
          return ListView.builder(
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
