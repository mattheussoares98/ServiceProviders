import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';

class ChecklistTemplateRequestModel extends ChecklistTemplateEntity
    implements DataConvertible<ChecklistTemplateEntity> {
  const ChecklistTemplateRequestModel({
    required super.id,
    required super.companyId,
    required super.name,
    super.description,
    super.categoryId,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory ChecklistTemplateRequestModel.fromEntity(
    ChecklistTemplateEntity entity,
  ) => ChecklistTemplateRequestModel(
    id: entity.id,
    companyId: entity.companyId,
    name: entity.name,
    description: entity.description,
    categoryId: entity.categoryId,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    deletedAt: entity.deletedAt,
  );

  factory ChecklistTemplateRequestModel.fromJson(MapDynamic json) =>
      ChecklistTemplateRequestModel(
        id: json['id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        categoryId: json['category_id'] as String?,
        createdAt: (json['created_at'] as String?).toUtcDateTime() ??
            DateTime.now().toUtc(),
        updatedAt: (json['updated_at'] as String?).toUtcDateTime() ??
            DateTime.now().toUtc(),
        deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
      );

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'name': name,
    'description': description,
    'category_id': categoryId,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
  };

  @override
  ChecklistTemplateEntity toEntity() => ChecklistTemplateEntity(
    id: id,
    companyId: companyId,
    name: name,
    description: description,
    categoryId: categoryId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
