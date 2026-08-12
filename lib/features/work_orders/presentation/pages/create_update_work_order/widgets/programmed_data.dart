part of '../create_update_work_order_page.dart';

class _ProgrammedData extends StatelessWidget {
  const _ProgrammedData({required this.scheduledDate, required this.onChanged});
  final DateTime? scheduledDate;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(child: BaseText('Data programada'.hardcoded)),
        gapH8,
        Expanded(
          child: InkWell(
            onTap: () async {
              final newDate = await GetNewDate.get(
                minimumDate: now,
                maximumDate: now.add(const Duration(days: 365 * 10)),
                context: context,
                currentSelectedDate: scheduledDate,
              );
              if (newDate != null) {
                onChanged(newDate);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.p8),
              decoration: BoxDecoration(
                color: context.theme.disabledColor.withAlpha(30),
                borderRadius: BorderRadius.circular(Sizes.p8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: BaseText(
                      scheduledDate == null
                          ? 'Selecionar'.hardcoded
                          : scheduledDate!.formatDate(),
                    ),
                  ),
                  if (screenWidth > 250) ...[
                    if (scheduledDate != null)
                      BaseIconButton(
                        padding: EdgeInsets.zero,
                        platformIcon: const PlatformIcon(
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
