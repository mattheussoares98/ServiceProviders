import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/pages/customers/widgets/customer_card.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

@RoutePage()
class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      onRefresh: () => context.read<CustomersCubit>().loadCustomers(),
      isScrollable: false,
      appBar: BaseAppBar(
        title: 'Clientes'.hardcoded,
        actions: [
          BaseIconButton(
            onPressed: () =>
                context.read<CustomersCubit>().navigateToCreateUpdateCustomer(),
            platformIcon: const PlatformIcon(
              materialIcon: Icons.add,
              cupertinoIcon: CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body: BaseStateView<CustomersCubit, CustomersState, List<CustomerEntity>>(
        dataSelector: (state) => state.customers,
        onRetry: () => context.read<CustomersCubit>().loadCustomers(),
        builder: (context, customers) {
          if (customers.isEmpty) {
            return Center(
              child: BaseText.bodyMedium('Nenhum cliente cadastrado'.hardcoded),
            );
          }

          final sorted = [...customers]
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );

          return ResponsiveListFlow(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              return CustomerCard(customer: sorted[index]);
            },
          );
        },
      ),
    );
  }
}
