import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity
    implements DataConvertible<CategoryEntity> {
  const CategoryModel({
    required super.id,
    required super.companyId,
    required super.name,
    super.description,
    super.color,
    required super.createdAt,
    super.deletedAt,
  });

  factory CategoryModel.fromEntity(CategoryEntity entity) => CategoryModel(
    id: entity.id,
    companyId: entity.companyId,
    name: entity.name,
    description: entity.description,
    color: entity.color,
    createdAt: entity.createdAt,
    deletedAt: entity.deletedAt,
  );

  factory CategoryModel.fromJson(MapDynamic json) => CategoryModel(
    id: json['id'] as String? ?? '',
    companyId: json['company_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    color: json['color'] as String?,
    createdAt: (json['created_at'] as String?).toUtcDateTime() ??
        DateTime.now().toUtc(),
    deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
  );

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'name': name,
    'description': description,
    'color': color,
    'created_at': createdAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
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
