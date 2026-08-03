import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_response_answer_entity.dart';

class ChecklistResponseAnswerModel extends ChecklistResponseAnswerEntity
    implements DataConvertible<ChecklistResponseAnswerEntity> {
  const ChecklistResponseAnswerModel({
    required super.id,
    required super.workOrderId,
    required super.checklistItemId,
    super.booleanValue,
    super.textValue,
    super.numberValue,
    super.photoUrl,
    super.selectedOption,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ChecklistResponseAnswerModel.fromEntity(
    ChecklistResponseAnswerEntity entity,
  ) {
    return ChecklistResponseAnswerModel(
      id: entity.id,
      workOrderId: entity.workOrderId,
      checklistItemId: entity.checklistItemId,
      booleanValue: entity.booleanValue,
      textValue: entity.textValue,
      numberValue: entity.numberValue,
      photoUrl: entity.photoUrl,
      selectedOption: entity.selectedOption,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory ChecklistResponseAnswerModel.fromJson(MapDynamic json) {
    return ChecklistResponseAnswerModel(
      id: json['id'] as String? ?? '',
      workOrderId: json['work_order_id'] as String? ?? '',
      checklistItemId: json['checklist_item_id'] as String? ?? '',
      booleanValue: json['boolean_value'] as bool?,
      textValue: json['text_value'] as String?,
      numberValue: (json['number_value'] as num?)?.toDouble(),
      photoUrl: json['photo_url'] as String?,
      selectedOption: json['selected_option'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  MapDynamic toJson() {
    return {
      'id': id,
      'work_order_id': workOrderId,
      'checklist_item_id': checklistItemId,
      'boolean_value': booleanValue,
      'text_value': textValue,
      'number_value': numberValue,
      'photo_url': photoUrl,
      'selected_option': selectedOption,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  ChecklistResponseAnswerEntity toEntity() {
    return ChecklistResponseAnswerEntity(
      id: id,
      workOrderId: workOrderId,
      checklistItemId: checklistItemId,
      booleanValue: booleanValue,
      textValue: textValue,
      numberValue: numberValue,
      photoUrl: photoUrl,
      selectedOption: selectedOption,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
