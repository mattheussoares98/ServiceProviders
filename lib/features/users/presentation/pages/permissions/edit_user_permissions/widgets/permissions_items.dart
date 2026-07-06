import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/permissions/permissions_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_segmented_buttons.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

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
          child: ExpansionTile(
            title: BaseText.titleMedium(resource.label),
            subtitle: _Subtitle(resource: resource),
            children: PermissionAction.values.map((action) {
              return BlocSelector<PermissionsCubit, PermissionsState, bool?>(
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
                                : (value) => cubit.setUserPermissionOverride(
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
        );
      },
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.resource});
  final ResourceType resource;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      PermissionsCubit,
      PermissionsState,
      Map<PermissionAction, bool?>?
    >(
      selector: (state) => state.draftUserPermissions[resource],
      builder: (context, permissions) {
        if (permissions == null) {
          return const SizedBox.shrink();
        }
        return Row(
          children: permissions.entries.map((entry) {
            final value = entry.value;
            final Color color;
            if (value == null) {
              color = Colors.lightBlue;
            } else if (!value) {
              color = Colors.red;
            } else {
              color = Colors.green;
            }
            return Padding(
              padding: const EdgeInsets.only(right: Sizes.p8),
              child: BaseText.bodySmall(entry.key.label, color: color),
            );
          }).toList(),
        );
      },
    );
  }
}
