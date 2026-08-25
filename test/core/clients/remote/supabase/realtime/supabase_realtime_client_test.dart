import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockRealtimeChannel extends Mock implements RealtimeChannel {}

class _FakeRealtimeChannel extends Fake implements RealtimeChannel {}

void main() {
  setUpAll(() {
    registerFallbackValue(PostgresChangeEvent.all);
    registerFallbackValue(_FakeRealtimeChannel());
  });

  late _MockSupabaseClient mockSupabaseClient;
  late _MockRealtimeChannel mockChannel;
  late SupabaseRealtimeClientImpl realtimeClient;

  setUp(() {
    mockSupabaseClient = _MockSupabaseClient();
    mockChannel = _MockRealtimeChannel();
    realtimeClient = SupabaseRealtimeClientImpl(mockSupabaseClient);

    when(() => mockSupabaseClient.channel(any())).thenReturn(mockChannel);
    when(
      () => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        filter: any(named: 'filter'),
        callback: any(named: 'callback'),
      ),
    ).thenReturn(mockChannel);
    when(() => mockChannel.subscribe(any())).thenReturn(mockChannel);
    when(() => mockSupabaseClient.removeChannel(any())).thenAnswer(
      (_) async => 'ok',
    );
  });

  test('streamTableChanges subscribes to channel with correct parameters', () {
    final stream = realtimeClient.streamTableChanges(
      table: 'work_orders',
    );

    expect(stream, isA<Stream<PostgresChangePayload>>());
    verify(() => mockSupabaseClient.channel(any())).called(1);
    verify(
      () => mockChannel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'work_orders',
        callback: any(named: 'callback'),
      ),
    ).called(1);
    verify(() => mockChannel.subscribe(any())).called(1);
  });

  test('streamTableChanges removes channel when stream subscription is cancelled', () async {
    final stream = realtimeClient.streamTableChanges(
      table: 'work_orders',
    );

    final subscription = stream.listen((_) {});
    await subscription.cancel();

    verify(() => mockSupabaseClient.removeChannel(mockChannel)).called(1);
  });
}
