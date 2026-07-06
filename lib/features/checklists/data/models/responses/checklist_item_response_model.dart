import 'dart:convert';

import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';

class ChecklistItemResponseModel extends ChecklistItemEntity
    implements DataConvertible<ChecklistItemEntity> {
  const ChecklistItemResponseModel({
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

  factory ChecklistItemResponseModel.fromEntity(ChecklistItemEntity entity) =>
      ChecklistItemResponseModel(
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

  factory ChecklistItemResponseModel.fromJson(MapDynamic json) {
    List<String>? parsedOptions;
    if (json['options'] != null) {
      if (json['options'] is String) {
        try {
          final decoded = jsonDecode(json['options'] as String);
          if (decoded is List) {
            parsedOptions = decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {
          // If parsing fails, handle gracefully
        }
      } else if (json['options'] is List) {
        parsedOptions = (json['options'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    return ChecklistItemResponseModel(
      id: json['id'] as String? ?? '',
      templateId: json['template_id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      type: ChecklistItemType.fromCode(json['type'] as String? ?? 'boolean'),
      isRequired: json['is_required'] as bool? ?? false,
      options: parsedOptions,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

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
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
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
