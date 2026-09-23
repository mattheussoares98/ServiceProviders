import 'package:collection/collection.dart';

enum PlanType {
  free('free'),
  paid('paid');

  const PlanType(this.code);
  final String code;

  bool get isFree => this == PlanType.free;
  bool get isPaid => this == PlanType.paid;

  static PlanType? fromCode(String? code) =>
      PlanType.values.firstWhereOrNull((e) => e.code == code);
}
