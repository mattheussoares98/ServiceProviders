part of 'searchable_customer_picker_modal.dart';

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({
    required this.customer,
    required this.isSelected,
    required this.onTap,
  });

  final CustomerEntity customer;
  final bool isSelected;
  final VoidCallback onTap;

  String? _buildSubtitle() {
    final buffer = StringBuffer();
    void writePart(String text) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      buffer.write(text);
    }

    final doc = customer.document?.trim();
    if (doc != null && doc.isNotEmpty) {
      writePart(doc);
    }
    final contact = customer.contactName?.trim();
    if (contact != null && contact.isNotEmpty) {
      writePart(contact);
    }
    final phone = customer.contactPhone?.trim();
    if (phone != null && phone.isNotEmpty) {
      writePart(phone);
    } else {
      final email = customer.contactEmail?.trim();
      if (email != null && email.isNotEmpty) {
        writePart(email);
      }
    }
    final city = customer.city?.trim();
    if (city != null && city.isNotEmpty) {
      writePart(city);
    }

    return buffer.isEmpty ? null : buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _buildSubtitle();

    return Padding(
      key: ValueKey('CustomerTile_${customer.id}'),
      padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
      child: BaseListTile(
        title: customer.name,
        subtitle: subtitle,
        platformIcon: PlatformIcon(
          materialIcon: Icons.person_outline,
          cupertinoIcon: CupertinoIcons.person,
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.onSurface,
        ),
        tileColor: isSelected
            ? context.colorScheme.primary.withValues(alpha: 0.08)
            : null,
        borderRadius: BorderRadius.circular(Sizes.p8),
        trailing: isSelected
            ? PlatformIcon(
                materialIcon: Icons.check_circle,
                cupertinoIcon: CupertinoIcons.checkmark_circle_fill,
                color: context.colorScheme.primary,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
