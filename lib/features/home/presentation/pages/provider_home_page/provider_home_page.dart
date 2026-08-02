import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/provider_home/provider_home_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/provider_home_page/widgets/provider_home_drawer.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';

@RoutePage()
class ProviderHomePage extends StatelessWidget {
  const ProviderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetIt.I<ProviderHomeCubit>()),
        BlocProvider<ModeSwitcherCubit>(
          lazy: false,
          create: (context) =>
              GetIt.I<ModeSwitcherCubit>()..checkEligibilityAndLoadMode(),
        ),
      ],
      child: BaseScaffold(
        drawer: const ProviderHomeDrawer(),
        appBar: BaseAppBar(title: 'Prestador de serviços'.hardcoded),
        body: Center(child: Text('Provider Home'.hardcoded)),
      ),
    );
  }
}
