import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class CustomerDeleteButton extends StatelessWidget {
  const CustomerDeleteButton({super.key, required this.customer});

  final CustomerEntity customer;

  @override
  Widget build(BuildContext context) {
    return BaseIconButton(
      onPressed: () async {
        final proceed = await showAlertDialog(
          context: context,
          title: 'Atenção!'.hardcoded,
          contentText: 'Deseja realmente excluir o cliente "${customer.name}"?'
              .hardcoded,
          defaultActionText: 'Sim'.hardcoded,
          cancelActionText: 'Não'.hardcoded,
        );
        if (proceed == true && context.mounted) {
          final succeeds = await context.read<CustomersCubit>().deleteCustomer(
            customer.id,
          );
          if (succeeds && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      platformIcon: const PlatformIcon(
        materialIcon: Icons.delete_outline,
        cupertinoIcon: CupertinoIcons.trash,
        color: Colors.red,
      ),
    );
  }
}
