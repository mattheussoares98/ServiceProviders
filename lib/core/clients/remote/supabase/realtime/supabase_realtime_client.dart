import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SupabaseRealtimeClient {
  Stream<PostgresChangePayload> streamTableChanges({
    required String table,
    String schema = 'public',
    PostgresChangeEvent event = PostgresChangeEvent.all,
    PostgresChangeFilter? filter,
  });
}

@LazySingleton(as: SupabaseRealtimeClient)
final class SupabaseRealtimeClientImpl implements SupabaseRealtimeClient {
  const SupabaseRealtimeClientImpl(this._client);

  final SupabaseClient _client;

  @override
  Stream<PostgresChangePayload> streamTableChanges({
    required String table,
    String schema = 'public',
    PostgresChangeEvent event = PostgresChangeEvent.all,
    PostgresChangeFilter? filter,
  }) {
    final controller = StreamController<PostgresChangePayload>.broadcast();
    final channelName = 'realtime:$schema:$table:${DateTime.now().microsecondsSinceEpoch}';
    final channel = _client.channel(channelName);

    channel.onPostgresChanges(
      event: event,
      schema: schema,
      table: table,
      filter: filter,
      callback: (payload) {
        if (!controller.isClosed) {
          controller.add(payload);
        }
      },
    ).subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }
}
