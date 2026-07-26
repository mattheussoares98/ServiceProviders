import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

extension ServiceProviderInvitationStatusUiExtension
    on ServiceProviderInvitationStatus {
  Color get color {
    switch (this) {
      case ServiceProviderInvitationStatus.pending:
        return Colors.orange.shade700;
      case ServiceProviderInvitationStatus.accepted:
        return Colors.green.shade700;
      case ServiceProviderInvitationStatus.rejected:
        return Colors.red;
      case ServiceProviderInvitationStatus.expired:
        return Colors.grey.shade600;
    }
  }

  PlatformIcon get platformIcon {
    switch (this) {
      case ServiceProviderInvitationStatus.pending:
        return const PlatformIcon(
          materialIcon: Icons.mark_email_unread_outlined,
          cupertinoIcon: CupertinoIcons.mail,
        );
      case ServiceProviderInvitationStatus.accepted:
        return const PlatformIcon(
          materialIcon: Icons.check_circle_outline,
          cupertinoIcon: CupertinoIcons.checkmark_circle,
        );
      case ServiceProviderInvitationStatus.rejected:
        return const PlatformIcon(
          materialIcon: Icons.cancel_outlined,
          cupertinoIcon: CupertinoIcons.xmark_circle,
        );
      case ServiceProviderInvitationStatus.expired:
        return const PlatformIcon(
          materialIcon: Icons.history,
          cupertinoIcon: CupertinoIcons.clock,
        );
    }
  }
}
