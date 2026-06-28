import 'package:clean_architecture/core/domain/entities/selectable_item.dart';
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
import 'package:get_it/get_it.dart';

class PermissionsItems extends StatelessWidget {
  const PermissionsItems({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = GetIt.I.get<PermissionsCubit>();
    final isAdmin = context.select<PermissionsCubit, bool>(
      (cubit) => cubit.state.isAdmin,
    );
    return ResponsiveListFlow(
      maxItemWidth: 250,
      isSliver: true,
      itemCount: ResourceType.values.length,
      itemBuilder: (context, index) {
        final resource = ResourceType.values[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Column(
              children: [
                BaseText.bodyMedium(
                  resource.label,
                  fontWeight: FontWeight.bold,
                ),
                const Divider(height: Sizes.p20),
                Column(
                  children: PermissionAction.values.map((action) {
                    final currentValue =
                        cubit.state.draftUserPermissions[resource]?[action];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: Sizes.p12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BaseText(action.label),
                          gapH8,
                          BaseSegmentedButtons<_ThreeStateValue>(
                            items: <SelectableItem<_ThreeStateValue>>[
                              SelectableItemImpl<_ThreeStateValue>(
                                name: 'Herdar'.hardcoded,
                                value: _ThreeStateValue.inherit,
                                color: context.theme.primaryColor,
                              ),
                              SelectableItemImpl<_ThreeStateValue>(
                                name: 'Ativo'.hardcoded,
                                value: _ThreeStateValue.active,
                                color: Colors.green.shade600,
                              ),
                              SelectableItemImpl<_ThreeStateValue>(
                                name: 'Inativo'.hardcoded,
                                value: _ThreeStateValue.inactive,
                                color: Colors.red.shade600,
                              ),
                            ],
                            selectedValue: _ThreeStateValue.fromBool(
                              currentValue,
                            ),
                            onChanged: isAdmin
                                ? null
                                : (value) => cubit.setUserPermissionOverride(
                                    resource,
                                    action,
                                    value.toBool(),
                                  ),
                          ),
                        ],
                      ),
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

enum _ThreeStateValue {
  inherit,
  active,
  inactive;

  bool? toBool() {
    switch (this) {
      case _ThreeStateValue.inherit:
        return null;
      case _ThreeStateValue.active:
        return true;
      case _ThreeStateValue.inactive:
        return false;
    }
  }

  static _ThreeStateValue fromBool(bool? value) {
    if (value == null) return _ThreeStateValue.inherit;
    return value ? _ThreeStateValue.active : _ThreeStateValue.inactive;
  }
}
