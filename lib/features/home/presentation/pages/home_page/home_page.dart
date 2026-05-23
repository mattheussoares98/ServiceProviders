import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:clean_architecture/features/home/presentation/pages/home_page/widgets/home_drawer.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (context) => GetIt.I<HomeCubit>(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: BaseAppBar(
        title: 'HomePage'.hardcoded,
        leading: Builder(
          builder: (context) => BaseIconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            platformIcon: PlatformIcon(
              materialIcon: Icons.menu,
              cupertinoIcon: CupertinoIcons.bars,
              size: 24,
              color: context.colorScheme.onSurface,
            ),
            disableSplash: true,
          ),
        ),
      ),
      drawer: const HomeDrawer(),
      body: const SafeArea(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center),
        ),
      ),
    );
  }
}
