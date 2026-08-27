part of 'escalation_parameters_card.dart';

class _CardHeader extends StatelessWidget {
  const _CardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const PlatformIcon(
          materialIcon: Icons.notifications_active_outlined,
          cupertinoIcon: CupertinoIcons.bell,
        ),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BaseText.titleMedium('Escalonamento & avisos de SLA'.hardcoded),
              gapH4,
              BaseText.bodySmall(
                'Configure avisos prévios de expiração e notificações em cascata para ordens atrasadas.'
                    .hardcoded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
