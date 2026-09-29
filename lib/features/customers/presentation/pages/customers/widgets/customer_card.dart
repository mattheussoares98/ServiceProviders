import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({super.key, required this.customer});

  final CustomerEntity customer;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[];
    if (customer.document != null && customer.document!.isNotEmpty) {
      subtitleParts.add(customer.document!);
    }
    if (customer.contactPhone != null && customer.contactPhone!.isNotEmpty) {
      subtitleParts.add(customer.contactPhone!);
    } else if (customer.contactEmail != null &&
        customer.contactEmail!.isNotEmpty) {
      subtitleParts.add(customer.contactEmail!);
    }

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => context
            .read<CustomersCubit>()
            .navigateToCreateUpdateCustomer(customer: customer),
        child: BaseListTile(
          title: customer.name,
          subtitle: subtitleParts.isNotEmpty ? subtitleParts.join(' • ') : null,
          subtitleMaxLines: 2,
          padding: const EdgeInsets.all(Sizes.p8),
          platformIcon: const PlatformIcon(
            materialIcon: Icons.person,
            cupertinoIcon: CupertinoIcons.person_fill,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BaseIconButton(
                onPressed: () => context
                    .read<CustomersCubit>()
                    .navigateToCreateUpdateCustomer(customer: customer),
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.edit_outlined,
                  cupertinoIcon: CupertinoIcons.pencil,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
