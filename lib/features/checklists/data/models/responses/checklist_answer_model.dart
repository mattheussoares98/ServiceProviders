import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';

class ChecklistAnswerModel extends ChecklistAnswerEntity
    implements DataConvertible<ChecklistAnswerEntity> {
  const ChecklistAnswerModel({
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

  factory ChecklistAnswerModel.fromEntity(ChecklistAnswerEntity entity) {
    return ChecklistAnswerModel(
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

  factory ChecklistAnswerModel.fromJson(MapDynamic json) {
    return ChecklistAnswerModel(
      id: json['id'] as String? ?? '',
      workOrderId: json['work_order_id'] as String? ?? '',
      checklistItemId: json['checklist_item_id'] as String? ?? '',
      booleanValue: json['boolean_value'] as bool?,
      textValue: json['text_value'] as String?,
      numberValue: (json['number_value'] as num?)?.toDouble(),
      photoUrl: json['photo_url'] as String?,
      selectedOption: json['selected_option'] as String?,
      createdAt: (json['created_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      updatedAt: (json['updated_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
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
      'created_at': createdAt.toIsoUtcString(),
      'updated_at': updatedAt.toIsoUtcString(),
    };
  }

  @override
  ChecklistAnswerEntity toEntity() {
    return ChecklistAnswerEntity(
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
