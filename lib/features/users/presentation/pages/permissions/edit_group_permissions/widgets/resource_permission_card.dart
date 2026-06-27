import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_switch.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ResourcePermissionCard extends HookWidget {
  const ResourcePermissionCard({
    super.key,
    required this.resource,
    required this.notifier,
    required this.isAdminGroup,
  });

  final ResourceType resource;
  final ValueNotifier<Set<PermissionAction>> notifier;
  final bool isAdminGroup;

  @override
  Widget build(BuildContext context) {
    final actions = useValueListenable(notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaseText(resource.label),
            const Divider(height: Sizes.p20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              children: PermissionAction.values.map((action) {
                final hasPermission = actions.contains(action);

                return DefaultSwitch(
                  title: action.label,
                  value: hasPermission,
                  onChanged: isAdminGroup
                      ? null
                      : (value) {
                          final current = Set<PermissionAction>.from(
                            notifier.value,
                          );
                          if (value) {
                            current.add(action);
                          } else {
                            current.remove(action);
                          }
                          notifier.value = current;
                        },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
