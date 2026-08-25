import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/realtime_payload_mapper.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('RealtimePayloadMapper', () {
    test('maps insert payload correctly', () {
      final payload = PostgresChangePayload(
        eventType: PostgresChangeEvent.insert,
        newRecord: {'id': 'loc-1', 'company_id': 'comp-1', 'name': 'Bloco A'},
        oldRecord: {},
        schema: 'public',
        table: 'locations',
        errors: <dynamic>[],
        commitTimestamp: DateTime.now(),
      );

      final event = RealtimePayloadMapper.map(
        payload,
        (json) => json['name'] as String,
      );

      expect(event.eventType, RealtimeEventType.insert);
      expect(event.id, 'loc-1');
      expect(event.companyId, 'comp-1');
      expect(event.entity, 'Bloco A');
    });

    test('maps update payload correctly', () {
      final payload = PostgresChangePayload(
        eventType: PostgresChangeEvent.update,
        newRecord: {'id': 'loc-2', 'company_id': 'comp-1', 'name': 'Bloco B'},
        oldRecord: {'id': 'loc-2'},
        schema: 'public',
        table: 'locations',
        errors: <dynamic>[],
        commitTimestamp: DateTime.now(),
      );

      final event = RealtimePayloadMapper.map(
        payload,
        (json) => json['name'] as String,
      );

      expect(event.eventType, RealtimeEventType.update);
      expect(event.id, 'loc-2');
      expect(event.companyId, 'comp-1');
      expect(event.entity, 'Bloco B');
    });

    test('maps delete payload with oldRecord correctly', () {
      final payload = PostgresChangePayload(
        eventType: PostgresChangeEvent.delete,
        newRecord: {},
        oldRecord: {'id': 'loc-3', 'company_id': 'comp-1'},
        schema: 'public',
        table: 'locations',
        errors: <dynamic>[],
        commitTimestamp: DateTime.now(),
      );

      final event = RealtimePayloadMapper.map(
        payload,
        (json) => json['name'] as String,
      );

      expect(event.eventType, RealtimeEventType.delete);
      expect(event.id, 'loc-3');
      expect(event.companyId, 'comp-1');
      expect(event.entity, isNull);
    });

    test(
      'handles JSON parse exceptions gracefully by setting entity to null',
      () {
        final payload = PostgresChangePayload(
          eventType: PostgresChangeEvent.insert,
          newRecord: {'id': 'loc-4'},
          oldRecord: {},
          schema: 'public',
          table: 'locations',
          errors: <dynamic>[],
          commitTimestamp: DateTime.now(),
        );

        final event = RealtimePayloadMapper.map<String>(
          payload,
          (json) => throw const FormatException('Invalid data'),
        );

        expect(event.eventType, RealtimeEventType.insert);
        expect(event.id, 'loc-4');
        expect(event.entity, isNull);
      },
    );
  });
}
