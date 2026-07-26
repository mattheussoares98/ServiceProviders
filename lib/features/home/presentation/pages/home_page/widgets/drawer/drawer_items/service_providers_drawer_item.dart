import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_drawer_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class ServiceProvidersDrawerItem extends StatelessWidget {
  const ServiceProvidersDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDrawerItem(
      onTap: context.read<HomeCubit>().navigateToServiceProviders,
      title: 'Prestadores de Serviço'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.handyman_outlined,
        cupertinoIcon: CupertinoIcons.wrench_fill,
      ),
    );
  }
}
