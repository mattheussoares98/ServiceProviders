import 'package:clean_architecture/core/utils/extensions/date_time_extension.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/get_new_date.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgrammedData extends StatelessWidget {
  const ProgrammedData({
    required this.selectedScheduledDate,
    required this.onChanged,
    super.key,
  });
  final DateTime? selectedScheduledDate;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseText('Data programada'.hardcoded),
        gapH8,
        Expanded(
          child: InkWell(
            onTap: () async {
              final newDate = await GetNewDate.get(
                minimumDate: now,
                maximumDate: now.add(const Duration(days: 365 * 10)),
                context: context,
                currentSelectedDate: selectedScheduledDate,
              );
              if (newDate != null) {
                onChanged(newDate);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.p8),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withAlpha(30),
                borderRadius: BorderRadius.circular(Sizes.p8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: BaseText(
                      selectedScheduledDate == null
                          ? 'Selecionar'.hardcoded
                          : selectedScheduledDate!.formatDate(
                              DateFormatType.yMMMMd,
                            ),
                    ),
                  ),
                  if (selectedScheduledDate != null)
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: const PlatformIcon(
                        materialIcon: Icons.clear,
                        cupertinoIcon: CupertinoIcons.clear,
                        color: Colors.red,
                        size: 16,
                      ),
                      onPressed: () => onChanged(null),
                    )
                  else
                    const PlatformIcon(
                      materialIcon: Icons.calendar_today,
                      cupertinoIcon: CupertinoIcons.calendar,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
