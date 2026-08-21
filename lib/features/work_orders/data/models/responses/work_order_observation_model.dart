import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';

class WorkOrderObservationModel extends WorkOrderObservationEntity
    implements DataConvertible<WorkOrderObservationEntity> {
  const WorkOrderObservationModel({
    required super.id,
    required super.companyId,
    required super.workOrderId,
    required super.authorId,
    required super.authorProviderProfileId,
    required super.authorName,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WorkOrderObservationModel.fromEntity(
          WorkOrderObservationEntity entity) =>
      WorkOrderObservationModel(
        id: entity.id,
        companyId: entity.companyId,
        workOrderId: entity.workOrderId,
        authorId: entity.authorId,
        authorProviderProfileId: entity.authorProviderProfileId,
        authorName: entity.authorName,
        content: entity.content,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  factory WorkOrderObservationModel.fromJson(MapDynamic json) {
    final authorMap = json['author'] as MapDynamic?;
    final providerAuthorMap = json['provider_author'] as MapDynamic?;

    return WorkOrderObservationModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      workOrderId: json['work_order_id'] as String? ?? '',
      authorId: json['author_id'] as String?,
      authorProviderProfileId: json['author_provider_profile_id'] as String?,
      authorName:
          authorMap?['name'] as String? ??
          providerAuthorMap?['name'] as String? ??
          'Usuário',
      content: json['content'] as String? ?? '',
      createdAt: (json['created_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      updatedAt: (json['updated_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
    );
  }

  @override
  MapDynamic toJson() => {
        'id': id,
        'company_id': companyId,
        'work_order_id': workOrderId,
        'author_id': authorId,
        'author_provider_profile_id': authorProviderProfileId,
        'content': content,
        'created_at': createdAt.toIsoUtcString(),
        'updated_at': updatedAt.toIsoUtcString(),
      };

  @override
  WorkOrderObservationEntity toEntity() => WorkOrderObservationEntity(
        id: id,
        companyId: companyId,
        workOrderId: workOrderId,
        authorId: authorId,
        authorProviderProfileId: authorProviderProfileId,
        authorName: authorName,
        content: content,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
