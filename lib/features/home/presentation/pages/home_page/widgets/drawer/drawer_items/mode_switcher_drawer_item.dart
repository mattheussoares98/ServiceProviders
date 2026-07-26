import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/mode_switcher_page.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_drawer_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';

/// Navigation item for the home drawer to switch application access mode.
class ModeSwitcherDrawerItem extends StatelessWidget {
  const ModeSwitcherDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ModeSwitcherCubit>(
      create: (context) =>
          GetIt.I<ModeSwitcherCubit>()..checkEligibilityAndLoadMode(),
      child: BlocSelector<ModeSwitcherCubit, ModeSwitcherState, bool>(
        selector: (state) => state.canSwitchMode,
        builder: (context, canSwitchMode) {
          if (!canSwitchMode) return const SizedBox.shrink();
          return BaseDrawerItem(
            title: 'Alternar modo de acesso'.hardcoded,
            platformIcon: const PlatformIcon(
              materialIcon: Icons.swap_horiz_outlined,
              cupertinoIcon: CupertinoIcons.arrow_2_squarepath,
            ),
            onTap: () => showModalPage<void>(const ModeSwitcherPage(), context),
          );
        },
      ),
    );
  }
}
