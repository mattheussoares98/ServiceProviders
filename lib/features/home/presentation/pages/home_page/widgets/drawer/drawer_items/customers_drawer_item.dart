import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_drawer_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class CustomersDrawerItem extends StatelessWidget {
  const CustomersDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CompanyCubit, CompanyState, bool>(
      selector: (state) => state.company?.workType.supportsCustomers ?? false,
      builder: (context, supportsCustomers) {
        if (!supportsCustomers) return const SizedBox.shrink();
        return BaseDrawerItem(
          onTap: context.read<HomeCubit>().navigateToCustomers,
          title: 'Clientes'.hardcoded,
          platformIcon: const PlatformIcon(
            materialIcon: Icons.people_outline,
            cupertinoIcon: CupertinoIcons.person_2,
          ),
        );
      },
    );
  }
}
