import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class RealtimePayloadMapper {
  const RealtimePayloadMapper._();

  static RealtimeEvent<T> map<T>(
    PostgresChangePayload payload,
    T Function(MapDynamic json) fromJson,
  ) {
    final eventType = switch (payload.eventType) {
      PostgresChangeEvent.insert => RealtimeEventType.insert,
      PostgresChangeEvent.update => RealtimeEventType.update,
      PostgresChangeEvent.delete => RealtimeEventType.delete,
      _ => RealtimeEventType.update,
    };

    final record = payload.newRecord.isNotEmpty
        ? payload.newRecord
        : payload.oldRecord;

    final id = (record['id'] as String?) ?? '';
    final companyId = record['company_id'] as String?;

    T? entity;
    if (payload.newRecord.isNotEmpty) {
      try {
        entity = fromJson(MapDynamic.from(payload.newRecord));
      } catch (_) {
        entity = null;
      }
    }

    return RealtimeEvent<T>(
      eventType: eventType,
      id: id,
      companyId: companyId,
      entity: entity,
    );
  }
}
