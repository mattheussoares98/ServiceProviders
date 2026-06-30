import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/presentation/cubits/permissions/permissions_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_segmented_buttons.dart';
import 'package:clean_architecture/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PermissionsItems extends StatelessWidget {
  const PermissionsItems({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PermissionsCubit>();
    final isAdmin = context.select<PermissionsCubit, bool>(
      (cubit) => cubit.state.isAdmin,
    );
    return ResponsiveListFlow(
      maxItemWidth: 300,
      isSliver: true,
      itemCount: ResourceType.values.length,
      itemBuilder: (context, index) {
        final resource = ResourceType.values[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.p8),
            child: Column(
              children: [
                BaseText.bodyMedium(
                  resource.label,
                  fontWeight: FontWeight.bold,
                ),
                const Divider(height: Sizes.p20),
                Column(
                  children: PermissionAction.values.map((action) {
                    return BlocSelector<
                      PermissionsCubit,
                      PermissionsState,
                      bool?
                    >(
                      selector: (state) =>
                          state.draftUserPermissions[resource]?[action],
                      builder: (context, currentValue) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: Sizes.p12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: BaseText(
                                  action.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              gapW8,
                              Expanded(
                                flex: 8,
                                child: BaseSegmentedButtons<bool?>(
                                  items: const [null, true, false],
                                  selectedValue: currentValue,
                                  onChanged: isAdmin
                                      ? null
                                      : (value) =>
                                            cubit.setUserPermissionOverride(
                                              resource,
                                              action,
                                              value,
                                            ),
                                  itemLabelBuilder: (value) {
                                    switch (value) {
                                      case null:
                                        return 'Herdar'.hardcoded;
                                      case true:
                                        return 'Ativo'.hardcoded;
                                      case false:
                                        return 'Inativo'.hardcoded;
                                    }
                                  },
                                  itemColorBuilder: (value) {
                                    switch (value) {
                                      case null:
                                        return context.theme.primaryColor;
                                      case true:
                                        return Colors.green.shade600;
                                      case false:
                                        return Colors.red.shade600;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
