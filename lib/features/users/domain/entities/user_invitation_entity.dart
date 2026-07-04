import 'package:equatable/equatable.dart';

class UserInvitationEntity extends Equatable {
  const UserInvitationEntity({
    required this.id,
    required this.email,
    required this.invitedAt,
    required this.companyId,
    required this.permissionGroupId,
    required this.name,
    this.confirmationSentAt,
  });

  final String id;
  final String email;
  final DateTime invitedAt;
  final String companyId;
  final String permissionGroupId;
  final String name;

  /// When the invite email was last dispatched by Supabase Auth.
  /// Null when the token has not been sent yet (rare edge case).
  final DateTime? confirmationSentAt;

  /// Returns true when the invite link is older than 24 hours (Supabase default).
  /// Update this constant if the OTP expiry is changed in the Supabase dashboard.
  static const int _inviteExpiryHours = 24;

  bool get isExpired {
    final sentAt = confirmationSentAt;
    if (sentAt == null) return false;
    return DateTime.now().toUtc().difference(sentAt.toUtc()).inHours >=
        _inviteExpiryHours;
  }

  UserInvitationEntity copyWith({
    String? id,
    String? email,
    DateTime? invitedAt,
    String? companyId,
    String? permissionGroupId,
    String? name,
    DateTime? confirmationSentAt,
    bool? annulConfirmationSentAt,
  }) {
    return UserInvitationEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      invitedAt: invitedAt ?? this.invitedAt,
      companyId: companyId ?? this.companyId,
      permissionGroupId: permissionGroupId ?? this.permissionGroupId,
      name: name ?? this.name,
      confirmationSentAt: annulConfirmationSentAt == true
          ? null
          : confirmationSentAt ?? this.confirmationSentAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    invitedAt,
    companyId,
    permissionGroupId,
    name,
    confirmationSentAt,
  ];
}
