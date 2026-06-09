import 'dart:convert';

import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_order.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late List<http.Request> requests;
  late SupabaseDatabaseClientImpl client;

  setUp(() {
    requests = [];
    final httpClient = _RecordingClient(
      requests: requests,
      responseFor: (request) {
        if (request.url.path.endsWith('/rpc/search_profiles')) {
          return http.Response(
            jsonEncode({'ok': true}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'GET' &&
            request.url.queryParameters['id'] != null) {
          return http.Response(
            jsonEncode({'id': 'user-1', 'name': 'Maria'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response(
          jsonEncode([
            {'id': 'user-1', 'name': 'Maria'},
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      },
    );

    final supabase = SupabaseClient(
      'https://example.supabase.co',
      'anon-key',
      httpClient: httpClient,
    );
    client = SupabaseDatabaseClientImpl(supabase);
  });

  test('selectOne applies columns and filters', () async {
    final result = await client.selectOne(
      table: 'user_profiles',
      columns: 'id,name',
      filters: [SupabaseFilter.eq('id', 'user-1')],
    );

    expect(result, {'id': 'user-1', 'name': 'Maria'});
    expect(requests.single.method, 'GET');
    expect(requests.single.url.path, '/rest/v1/user_profiles');
    expect(requests.single.url.queryParameters['select'], 'id,name');
    expect(requests.single.url.queryParameters['id'], 'eq.user-1');
  });

  test('selectList applies filters, order, and limit', () async {
    final result = await client.selectList(
      table: 'work_orders',
      filters: [
        SupabaseFilter.inList('status', const ['open', 'in_progress']),
      ],
      orderBy: const [SupabaseOrder(column: 'created_at')],
      limit: 10,
    );

    expect(result, [
      {'id': 'user-1', 'name': 'Maria'},
    ]);
    expect(
      requests.single.url.queryParameters['status'],
      'in.("open","in_progress")',
    );
    expect(
      requests.single.url.queryParameters['order'],
      'created_at.desc.nullslast',
    );
    expect(requests.single.url.queryParameters['limit'], '10');
  });

  test('write methods request returned rows', () async {
    await client.insert(table: 'companies', values: {'name': 'Empresa'});
    await client.update(
      table: 'companies',
      values: {'name': 'Empresa 2'},
      filters: [SupabaseFilter.eq('id', 'company-1')],
    );
    await client.upsert(
      table: 'companies',
      values: {'id': 'company-1', 'name': 'Empresa 2'},
      onConflict: 'id',
    );
    await client.delete(
      table: 'companies',
      filters: [SupabaseFilter.eq('id', 'company-1')],
    );

    expect(requests.map((request) => request.method), [
      'POST',
      'PATCH',
      'POST',
      'DELETE',
    ]);
    expect(
      requests.every((request) => request.url.queryParameters['select'] == '*'),
      isTrue,
    );
    expect(requests[2].url.queryParameters['on_conflict'], 'id');
  });

  test('rpc calls Supabase function endpoint', () async {
    final result = await client.rpc(
      functionName: 'search_profiles',
      params: {'query': 'Maria'},
    );

    expect(result, {'ok': true});
    expect(requests.single.method, 'POST');
    expect(requests.single.url.path, '/rest/v1/rpc/search_profiles');
  });
}

final class _RecordingClient extends http.BaseClient {
  _RecordingClient({required this.requests, required this.responseFor});

  final List<http.Request> requests;
  final http.Response Function(http.Request request) responseFor;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final finalizedRequest = request as http.Request;
    requests.add(finalizedRequest);
    final response = responseFor(finalizedRequest);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: finalizedRequest,
    );
  }
}
