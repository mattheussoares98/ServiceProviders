import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';

class ChecklistItemRequestModel extends ChecklistItemEntity
    implements DataConvertible<ChecklistItemEntity> {
  const ChecklistItemRequestModel({
    required super.id,
    required super.templateId,
    required super.companyId,
    required super.label,
    required super.type,
    required super.isRequired,
    super.options,
    required super.sortOrder,
    required super.createdAt,
    super.deletedAt,
  });

  factory ChecklistItemRequestModel.fromEntity(ChecklistItemEntity entity) =>
      ChecklistItemRequestModel(
        id: entity.id,
        templateId: entity.templateId,
        companyId: entity.companyId,
        label: entity.label,
        type: entity.type,
        isRequired: entity.isRequired,
        options: entity.options,
        sortOrder: entity.sortOrder,
        createdAt: entity.createdAt,
        deletedAt: entity.deletedAt,
      );

  factory ChecklistItemRequestModel.fromJson(MapDynamic json) =>
      ChecklistItemRequestModel(
        id: json['id'] as String? ?? '',
        templateId: json['template_id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        label: json['label'] as String? ?? '',
        type: ChecklistItemType.fromCode(json['type'] as String? ?? 'boolean'),
        isRequired: json['is_required'] as bool? ?? false,
        options: json['options'] != null
            ? (json['options'] is List
                  ? (json['options'] as List).map((e) => e.toString()).toList()
                  : null)
            : null,
        sortOrder: json['sort_order'] as int? ?? 0,
        createdAt: (json['created_at'] as String?).toUtcDateTime() ??
            DateTime.now().toUtc(),
        deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
      );

  @override
  MapDynamic toJson() => {
    'id': id,
    'template_id': templateId,
    'company_id': companyId,
    'label': label,
    'type': type.code,
    'is_required': isRequired,
    'options': options,
    'sort_order': sortOrder,
    'created_at': createdAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
  };

  @override
  ChecklistItemEntity toEntity() => ChecklistItemEntity(
    id: id,
    templateId: templateId,
    companyId: companyId,
    label: label,
    type: type,
    isRequired: isRequired,
    options: options,
    sortOrder: sortOrder,
    createdAt: createdAt,
    deletedAt: deletedAt,
  );
}
