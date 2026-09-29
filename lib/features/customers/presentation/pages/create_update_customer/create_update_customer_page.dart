import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/pages/create_update_customer/widgets/customer_delete_button.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/pages/create_update_customer/widgets/customer_form.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_running.dart';

@RoutePage()
class CreateUpdateCustomerPage extends HookWidget {
  const CreateUpdateCustomerPage({super.key, this.customer});

  final CustomerEntity? customer;

  @override
  Widget build(BuildContext context) {
    observeRunning([
      ObservedLoadingTarget(
        context.read<CustomersCubit>(),
        sections: {CustomersSections.save, CustomersSections.delete},
      ),
    ]);

    return BaseScaffold(
      appBar: BaseAppBar(
        title: customer != null
            ? 'Editando cliente'.hardcoded
            : 'Novo cliente'.hardcoded,
        actions: [
          if (customer != null) CustomerDeleteButton(customer: customer!),
        ],
      ),
      body: CustomerForm(customer: customer),
    );
  }
}
