import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/session/session_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_list_tile.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCompanyDrawerItem extends StatelessWidget {
  const AddCompanyDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SessionCubit, SessionState, bool>(
      selector: (state) => state.user.isAdmin,
      builder: (context, isLoading) {
        return BaseListTile(
          title: 'Adicionar empresa'.hardcoded,
          platformIcon: PlatformIcon(
            materialIcon: Icons.business,
            cupertinoIcon: CupertinoIcons.building_2_fill,
            color: context.theme.colorScheme.primary,
          ),
          onTap: () {
            Navigator.of(context).pop();
            context.read<HomeCubit>().navigateToCompany();
          },
        );
      },
    );
  }
}
