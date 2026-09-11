import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

class ResumeWorkRequestModel extends Equatable {
  const ResumeWorkRequestModel({
    required this.id,
    required this.workOrderId,
    required this.resumedAt,
    required this.resumedById,
  });

  factory ResumeWorkRequestModel.fromJson(MapDynamic json) =>
      ResumeWorkRequestModel(
        id: json['id'] as String? ?? '',
        workOrderId: json['work_order_id'] as String? ?? '',
        resumedAt:
            (json['resumed_at'] as String?).toUtcDateTime() ??
            DateTime.now().toUtc(),
        resumedById: json['resumed_by_id'] as String? ?? '',
      );

  final String id;
  final String workOrderId;
  final DateTime resumedAt;
  final String resumedById;

  MapDynamic toJson() => {
    'id': id,
    'work_order_id': workOrderId,
    'resumed_at': resumedAt.toIsoUtcString(),
    'resumed_by_id': resumedById,
  };

  @override
  List<Object?> get props => [id, workOrderId, resumedAt, resumedById];
}
