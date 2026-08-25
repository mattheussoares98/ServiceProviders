import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';

class CompanyParameterModel extends CompanyParameterEntity
    implements DataConvertible<CompanyParameterEntity> {
  const CompanyParameterModel({
    required super.id,
    required super.companyId,
    required super.maxOfflineDurationHours,
    required super.maxOfflinePendingRequests,
    required super.offlineAlertThrottleFrequency,
    required super.maxImageSizeMb,
    required super.maxVideoSizeMb,
    required super.maxPdfSizeMb,
    required super.maxDocumentSizeMb,
    required super.sandboxQuotaMb,
    required super.maxSyncAttempts,
    required super.inviteExpiryHours,
    super.advanceWarningMinutes = 60,
    super.advanceWarningGroupIds = const [],
    super.delayedNotificationIntervalMinutes = 60,
    super.escalationGroupIds = const [],
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory CompanyParameterModel.fromJson(MapDynamic json) {
    return CompanyParameterModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      maxOfflineDurationHours: json['max_offline_duration_hours'] as int? ?? 2,
      maxOfflinePendingRequests:
          json['max_offline_pending_requests'] as int? ?? 10,
      offlineAlertThrottleFrequency:
          json['offline_alert_throttle_frequency'] as int? ?? 3,
      maxImageSizeMb: json['max_image_size_mb'] as int? ?? 20,
      maxVideoSizeMb: json['max_video_size_mb'] as int? ?? 500,
      maxPdfSizeMb: json['max_pdf_size_mb'] as int? ?? 10,
      maxDocumentSizeMb: json['max_document_size_mb'] as int? ?? 5,
      sandboxQuotaMb: json['sandbox_quota_mb'] as int? ?? 1024,
      maxSyncAttempts: json['max_sync_attempts'] as int? ?? 3,
      inviteExpiryHours: json['invite_expiry_hours'] as int? ?? 24,
      advanceWarningMinutes: json['advance_warning_minutes'] as int? ?? 60,
      advanceWarningGroupIds:
          (json['advance_warning_group_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      delayedNotificationIntervalMinutes:
          json['delayed_notification_interval_minutes'] as int? ?? 60,
      escalationGroupIds:
          (json['escalation_group_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: (json['created_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      updatedAt: (json['updated_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
    );
  }

  factory CompanyParameterModel.fromEntity(CompanyParameterEntity entity) {
    return CompanyParameterModel(
      id: entity.id,
      companyId: entity.companyId,
      maxOfflineDurationHours: entity.maxOfflineDurationHours,
      maxOfflinePendingRequests: entity.maxOfflinePendingRequests,
      offlineAlertThrottleFrequency: entity.offlineAlertThrottleFrequency,
      maxImageSizeMb: entity.maxImageSizeMb,
      maxVideoSizeMb: entity.maxVideoSizeMb,
      maxPdfSizeMb: entity.maxPdfSizeMb,
      maxDocumentSizeMb: entity.maxDocumentSizeMb,
      sandboxQuotaMb: entity.sandboxQuotaMb,
      maxSyncAttempts: entity.maxSyncAttempts,
      inviteExpiryHours: entity.inviteExpiryHours,
      advanceWarningMinutes: entity.advanceWarningMinutes,
      advanceWarningGroupIds: entity.advanceWarningGroupIds,
      delayedNotificationIntervalMinutes:
          entity.delayedNotificationIntervalMinutes,
      escalationGroupIds: entity.escalationGroupIds,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'max_offline_duration_hours': maxOfflineDurationHours,
    'max_offline_pending_requests': maxOfflinePendingRequests,
    'offline_alert_throttle_frequency': offlineAlertThrottleFrequency,
    'max_image_size_mb': maxImageSizeMb,
    'max_video_size_mb': maxVideoSizeMb,
    'max_pdf_size_mb': maxPdfSizeMb,
    'max_document_size_mb': maxDocumentSizeMb,
    'sandbox_quota_mb': sandboxQuotaMb,
    'max_sync_attempts': maxSyncAttempts,
    'invite_expiry_hours': inviteExpiryHours,
    'advance_warning_minutes': advanceWarningMinutes,
    'advance_warning_group_ids': advanceWarningGroupIds,
    'delayed_notification_interval_minutes': delayedNotificationIntervalMinutes,
    'escalation_group_ids': escalationGroupIds,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
  };

  @override
  CompanyParameterEntity toEntity() {
    return CompanyParameterEntity(
      id: id,
      companyId: companyId,
      maxOfflineDurationHours: maxOfflineDurationHours,
      maxOfflinePendingRequests: maxOfflinePendingRequests,
      offlineAlertThrottleFrequency: offlineAlertThrottleFrequency,
      maxImageSizeMb: maxImageSizeMb,
      maxVideoSizeMb: maxVideoSizeMb,
      maxPdfSizeMb: maxPdfSizeMb,
      maxDocumentSizeMb: maxDocumentSizeMb,
      sandboxQuotaMb: sandboxQuotaMb,
      maxSyncAttempts: maxSyncAttempts,
      inviteExpiryHours: inviteExpiryHours,
      advanceWarningMinutes: advanceWarningMinutes,
      advanceWarningGroupIds: advanceWarningGroupIds,
      delayedNotificationIntervalMinutes: delayedNotificationIntervalMinutes,
      escalationGroupIds: escalationGroupIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}
