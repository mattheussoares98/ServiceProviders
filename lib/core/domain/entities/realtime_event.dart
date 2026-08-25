import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';

class RealtimeEvent<T> extends Equatable {
  const RealtimeEvent({
    required this.eventType,
    required this.id,
    this.companyId,
    this.entity,
  });

  final RealtimeEventType eventType;
  final String id;
  final String? companyId;
  final T? entity;

  RealtimeEvent<T> copyWith({
    RealtimeEventType? eventType,
    String? id,
    String? companyId,
    T? entity,
    bool? annulCompanyId,
    bool? annulEntity,
  }) {
    return RealtimeEvent<T>(
      eventType: eventType ?? this.eventType,
      id: id ?? this.id,
      companyId: annulCompanyId == true ? null : companyId ?? this.companyId,
      entity: annulEntity == true ? null : entity ?? this.entity,
    );
  }

  @override
  List<Object?> get props => [eventType, id, companyId, entity];
}
