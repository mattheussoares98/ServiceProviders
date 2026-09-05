import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_history/work_order_history_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class HistorySearchBar extends HookWidget {
  const HistorySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchQuery = context.select<WorkOrderHistoryCubit, String?>(
      (cubit) => cubit.state.searchQuery,
    );

    useEffect(() {
      if (searchQuery == null && searchController.text.isNotEmpty) {
        searchController.clear();
      }
      return null;
    }, [searchQuery]);

    return BaseTextFormField(
      controller: searchController,
      hintText: 'Buscar por alteração, prestador, anexo, valor...'.hardcoded,
      prefixIcon: const PlatformIcon(
        materialIcon: Icons.search,
        cupertinoIcon: CupertinoIcons.search,
        size: 20,
      ),
      suffixIcon: (searchQuery != null && searchQuery.isNotEmpty)
          ? BaseIconButton(
              onPressed: () {
                searchController.clear();
                context.read<WorkOrderHistoryCubit>().clearSearchQuery();
              },
              platformIcon: const PlatformIcon(
                materialIcon: Icons.clear,
                cupertinoIcon: CupertinoIcons.clear_circled,
                color: Colors.red,
              ),
            )
          : null,
      onChanged: (value) {
        context.read<WorkOrderHistoryCubit>().setSearchQuery(
          value.trimToNull(),
        );
      },
    );
  }
}
