part of '../create_provider_work_order_page.dart';

class _ProviderScheduledDate extends StatelessWidget {
  const _ProviderScheduledDate({
    required this.scheduledDate,
    required this.onChanged,
  });

  final DateTime? scheduledDate;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Row(
      children: [
        Expanded(child: BaseText('Data programada'.hardcoded)),
        BaseTextButton(
          onPressed: () async {
            final newDate = await GetNewDate.get(
              minimumDate: now,
              maximumDate: now.add(const Duration(days: 365 * 10)),
              context: context,
              currentSelectedDate: scheduledDate,
            );
            if (newDate != null) onChanged(newDate);
          },
          text: scheduledDate?.formatDate() ?? 'Selecionar'.hardcoded,
        ),
        if (scheduledDate != null)
          BaseIconButton(
            padding: EdgeInsets.zero,
            platformIcon: const PlatformIcon(
              materialIcon: Icons.clear,
              cupertinoIcon: CupertinoIcons.clear,
              size: 16,
            ),
            onPressed: () => onChanged(null),
          ),
      ],
    );
  }
}
