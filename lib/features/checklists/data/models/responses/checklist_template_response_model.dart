import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';

class ChecklistTemplateResponseModel extends ChecklistTemplateEntity
    implements DataConvertible<ChecklistTemplateEntity> {
  const ChecklistTemplateResponseModel({
    required super.id,
    required super.companyId,
    required super.name,
    super.description,
    super.categoryId,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory ChecklistTemplateResponseModel.fromEntity(
    ChecklistTemplateEntity entity,
  ) => ChecklistTemplateResponseModel(
    id: entity.id,
    companyId: entity.companyId,
    name: entity.name,
    description: entity.description,
    categoryId: entity.categoryId,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    deletedAt: entity.deletedAt,
  );

  factory ChecklistTemplateResponseModel.fromJson(MapDynamic json) =>
      ChecklistTemplateResponseModel(
        id: json['id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        categoryId: json['category_id'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'] as String)
            : null,
      );

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'name': name,
    'description': description,
    'category_id': categoryId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
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
