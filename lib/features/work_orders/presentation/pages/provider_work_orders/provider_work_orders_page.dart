import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/provider_home_page/widgets/provider_home_drawer.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/provider_work_orders/widgets/provider_company_selector.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/provider_work_orders/widgets/provider_lookups_loader.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/widgets/orders_items.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/widgets/work_order_filters.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';

/// Provider mode landing page. Lists every work order assigned to the provider
/// across all contracting companies, with an optional company filter.
///
/// Creating work orders (V2 §1.3 / Q5) goes through `CreateProviderWorkOrderPage`
/// rather than the shared form, which reads registries a provider cannot see.
@RoutePage()
class ProviderWorkOrdersPage extends StatelessWidget {
  const ProviderWorkOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkOrdersCubit>();

    return BaseScaffold(
      isScrollable: false,
      drawer: const ProviderHomeDrawer(),
      onRefresh: cubit.loadProviderWorkOrders,
      appBar: BaseAppBar(
        title: 'Minhas ordens de serviço'.hardcoded,
        actions: [
          BaseIconButton(
            onPressed: () => showModalPage<void>(
              WorkOrderFilters(currentFilter: cubit.state.activeFilter),
              context,
            ),
            platformIcon: const PlatformIcon(
              materialIcon: Icons.filter_list,
              cupertinoIcon: CupertinoIcons.slider_horizontal_3,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: cubit.navigateToCreateProviderWorkOrder,
        child: const PlatformIcon(
          materialIcon: Icons.add,
          cupertinoIcon: CupertinoIcons.add,
        ),
      ),
      body: const ProviderLookupsLoader(
        child: Column(
          children: [
            ProviderCompanySelector(),
            Expanded(child: OrdersItems()),
          ],
        ),
      ),
    );
  }
}
