import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';

class CategoryResponseModel extends CategoryEntity
    implements DataConvertible<CategoryEntity> {
  const CategoryResponseModel({
    required super.id,
    required super.companyId,
    required super.name,
    super.description,
    super.color,
    required super.createdAt,
    super.deletedAt,
  });

  factory CategoryResponseModel.fromEntity(CategoryEntity entity) =>
      CategoryResponseModel(
        id: entity.id,
        companyId: entity.companyId,
        name: entity.name,
        description: entity.description,
        color: entity.color,
        createdAt: entity.createdAt,
        deletedAt: entity.deletedAt,
      );

  factory CategoryResponseModel.fromJson(MapDynamic json) =>
      CategoryResponseModel(
        id: json['id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        color: json['color'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
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
    'color': color,
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };

  @override
  CategoryEntity toEntity() => CategoryEntity(
    id: id,
    companyId: companyId,
    name: name,
    description: description,
    color: color,
    createdAt: createdAt,
    deletedAt: deletedAt,
  );
}
