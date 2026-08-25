import 'package:equatable/equatable.dart';

class CompanyParameterEntity extends Equatable {
  const CompanyParameterEntity({
    required this.id,
    required this.companyId,
    required this.maxOfflineDurationHours,
    required this.maxOfflinePendingRequests,
    required this.offlineAlertThrottleFrequency,
    required this.maxImageSizeMb,
    required this.maxVideoSizeMb,
    required this.maxPdfSizeMb,
    required this.maxDocumentSizeMb,
    required this.sandboxQuotaMb,
    required this.maxSyncAttempts,
    required this.inviteExpiryHours,
    this.advanceWarningMinutes = 60,
    this.advanceWarningGroupIds = const [],
    this.delayedNotificationIntervalMinutes = 60,
    this.escalationGroupIds = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String companyId;
  final int maxOfflineDurationHours;
  final int maxOfflinePendingRequests;
  final int offlineAlertThrottleFrequency;
  final int maxImageSizeMb;
  final int maxVideoSizeMb;
  final int maxPdfSizeMb;
  final int maxDocumentSizeMb;
  final int sandboxQuotaMb;
  final int maxSyncAttempts;
  final int inviteExpiryHours;
  final int advanceWarningMinutes;
  final List<String> advanceWarningGroupIds;
  final int delayedNotificationIntervalMinutes;
  final List<String> escalationGroupIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  int get maxImageSizeBytes => maxImageSizeMb * 1024 * 1024;
  int get maxVideoSizeBytes => maxVideoSizeMb * 1024 * 1024;
  int get maxPdfSizeBytes => maxPdfSizeMb * 1024 * 1024;
  int get maxDocumentSizeBytes => maxDocumentSizeMb * 1024 * 1024;
  int get sandboxQuotaBytes => sandboxQuotaMb * 1024 * 1024;

  CompanyParameterEntity copyWith({
    String? id,
    String? companyId,
    int? maxOfflineDurationHours,
    int? maxOfflinePendingRequests,
    int? offlineAlertThrottleFrequency,
    int? maxImageSizeMb,
    int? maxVideoSizeMb,
    int? maxPdfSizeMb,
    int? maxDocumentSizeMb,
    int? sandboxQuotaMb,
    int? maxSyncAttempts,
    int? inviteExpiryHours,
    int? advanceWarningMinutes,
    List<String>? advanceWarningGroupIds,
    int? delayedNotificationIntervalMinutes,
    List<String>? escalationGroupIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulDeletedAt,
  }) {
    return CompanyParameterEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      maxOfflineDurationHours:
          maxOfflineDurationHours ?? this.maxOfflineDurationHours,
      maxOfflinePendingRequests:
          maxOfflinePendingRequests ?? this.maxOfflinePendingRequests,
      offlineAlertThrottleFrequency:
          offlineAlertThrottleFrequency ?? this.offlineAlertThrottleFrequency,
      maxImageSizeMb: maxImageSizeMb ?? this.maxImageSizeMb,
      maxVideoSizeMb: maxVideoSizeMb ?? this.maxVideoSizeMb,
      maxPdfSizeMb: maxPdfSizeMb ?? this.maxPdfSizeMb,
      maxDocumentSizeMb: maxDocumentSizeMb ?? this.maxDocumentSizeMb,
      sandboxQuotaMb: sandboxQuotaMb ?? this.sandboxQuotaMb,
      maxSyncAttempts: maxSyncAttempts ?? this.maxSyncAttempts,
      inviteExpiryHours: inviteExpiryHours ?? this.inviteExpiryHours,
      advanceWarningMinutes:
          advanceWarningMinutes ?? this.advanceWarningMinutes,
      advanceWarningGroupIds:
          advanceWarningGroupIds ?? this.advanceWarningGroupIds,
      delayedNotificationIntervalMinutes:
          delayedNotificationIntervalMinutes ??
          this.delayedNotificationIntervalMinutes,
      escalationGroupIds: escalationGroupIds ?? this.escalationGroupIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : (deletedAt ?? this.deletedAt),
    );
  }

  @override
  List<Object?> get props => [
    id,
    companyId,
    maxOfflineDurationHours,
    maxOfflinePendingRequests,
    offlineAlertThrottleFrequency,
    maxImageSizeMb,
    maxVideoSizeMb,
    maxPdfSizeMb,
    maxDocumentSizeMb,
    sandboxQuotaMb,
    maxSyncAttempts,
    inviteExpiryHours,
    advanceWarningMinutes,
    advanceWarningGroupIds,
    delayedNotificationIntervalMinutes,
    escalationGroupIds,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
