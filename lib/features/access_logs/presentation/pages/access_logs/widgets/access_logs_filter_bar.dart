import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/access_logs/presentation/cubits/access_logs/access_logs_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

class AccessLogsFilterBar extends StatelessWidget {
  const AccessLogsFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final startDate = context.select<AccessLogsCubit, DateTime?>(
      (cubit) => cubit.state.startDate,
    );
    final endDate = context.select<AccessLogsCubit, DateTime?>(
      (cubit) => cubit.state.endDate,
    );
    final selectedUserId = context.select<AccessLogsCubit, String?>(
      (cubit) => cubit.state.selectedUserId,
    );
    final users = context.select<AccessLogsCubit, List<UserProfileEntity>>(
      (cubit) => cubit.state.users,
    );

    Future<void> pickDateRange() async {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(now.year + 2),
        initialDateRange: startDate != null && endDate != null
            ? DateTimeRange(start: startDate, end: endDate)
            : null,
      );

      if (picked != null && context.mounted) {
        context.read<AccessLogsCubit>().setDateRange(
          startDate: picked.start,
          endDate: DateTime(
            picked.end.year,
            picked.end.month,
            picked.end.day,
            23,
            59,
            59,
          ),
        );
      }
    }

    final userItems = [
      DropdownMenuItem<String>(
        value: '',
        child: BaseText('Todos os usuários'.hardcoded),
      ),
      ...users.map((user) {
        final name = user.name.isNotEmpty ? user.name : user.email;
        return DropdownMenuItem<String>(value: user.id, child: BaseText(name));
      }),
    ];

    return Wrap(
      runSpacing: Sizes.p8,
      spacing: Sizes.p8,
      children: [
        SizedBox(
          width: ScreenUtil.I.type.maxWidth,
          child: Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  onTap: pickDateRange,
                  text: (startDate != null || endDate != null)
                      ? '${startDate?.formatDate() ?? ''} - ${endDate?.formatDate() ?? ''}'
                      : 'Filtrar período'.hardcoded,
                  platformIcon: const PlatformIcon(
                    materialIcon: Icons.date_range,
                    cupertinoIcon: CupertinoIcons.calendar,
                  ),
                ),
              ),
              if (startDate != null || endDate != null) ...[
                gapW8,
                BaseIconButton(
                  onPressed: () =>
                      context.read<AccessLogsCubit>().clearFilters(),
                  platformIcon: const PlatformIcon(
                    materialIcon: Icons.clear,
                    cupertinoIcon: CupertinoIcons.clear,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (users.isNotEmpty) ...[
          SizedBox(
            width: ScreenUtil.I.type.maxWidth,
            child: BaseDropDown<String>(
              label: 'Usuário'.hardcoded,
              selectedItem: selectedUserId ?? '',
              items: userItems,
              onChanged: (value) => context
                  .read<AccessLogsCubit>()
                  .setSelectedUser(value.isEmpty ? null : value),
            ),
          ),
        ],
      ],
    );
  }
}
