import 'package:equatable/equatable.dart';

/// Represents an execution response entry for a checklist item inside a work order execution.
class ChecklistAnswerEntity extends Equatable {
  const ChecklistAnswerEntity({
    required this.id,
    required this.workOrderId,
    required this.checklistItemId,
    required this.booleanValue,
    required this.textValue,
    required this.numberValue,
    required this.photoUrl,
    required this.selectedOption,
    required this.selectedOptions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChecklistAnswerEntity.empty({
    required String checklistItemId,
    String workOrderId = '',
  }) {
    final now = DateTime.now();
    return ChecklistAnswerEntity(
      id: '',
      workOrderId: workOrderId,
      checklistItemId: checklistItemId,
      createdAt: now,
      updatedAt: now,
      booleanValue: null,
      numberValue: null,
      photoUrl: null,
      selectedOption: null,
      selectedOptions: null,
      textValue: null,
    );
  }

  final String id;
  final String workOrderId;
  final String checklistItemId;
  final bool? booleanValue;
  final String? textValue;
  final double? numberValue;
  final String? photoUrl;
  final String? selectedOption;
  final List<String>? selectedOptions;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    workOrderId,
    checklistItemId,
    booleanValue,
    textValue,
    numberValue,
    photoUrl,
    selectedOption,
    selectedOptions,
    createdAt,
    updatedAt,
  ];

  ChecklistAnswerEntity copyWith({
    String? id,
    String? workOrderId,
    String? checklistItemId,
    bool? booleanValue,
    String? textValue,
    double? numberValue,
    String? photoUrl,
    String? selectedOption,
    List<String>? selectedOptions,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? annulBooleanValue,
    bool? annulTextValue,
    bool? annulNumberValue,
    bool? annulPhotoUrl,
    bool? annulSelectedOption,
    bool? annulSelectedOptions,
  }) {
    return ChecklistAnswerEntity(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      checklistItemId: checklistItemId ?? this.checklistItemId,
      booleanValue: annulBooleanValue == true
          ? null
          : booleanValue ?? this.booleanValue,
      textValue: annulTextValue == true ? null : textValue ?? this.textValue,
      numberValue: annulNumberValue == true
          ? null
          : numberValue ?? this.numberValue,
      photoUrl: annulPhotoUrl == true ? null : photoUrl ?? this.photoUrl,
      selectedOption: annulSelectedOption == true
          ? null
          : selectedOption ?? this.selectedOption,
      selectedOptions: annulSelectedOptions == true
          ? null
          : selectedOptions ?? this.selectedOptions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
