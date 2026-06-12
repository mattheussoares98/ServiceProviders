import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/session/session_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_drawer_item.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCompanyDrawerItem extends StatelessWidget {
  const AddCompanyDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SessionCubit, SessionState, bool>(
      selector: (state) => state.user.isAdmin,
      builder: (context, isAdmin) {
        if (!isAdmin) return const SizedBox.shrink();
        return BaseDrawerItem(
          onTap: () {
            context.read<HomeCubit>().navigateToCompany();
          },
          title: 'Adicionar empresa'.hardcoded,
          platformIcon: const PlatformIcon(
            materialIcon: Icons.business,
            cupertinoIcon: CupertinoIcons.building_2_fill,
          ),
        );
      },
    );
  }
}
