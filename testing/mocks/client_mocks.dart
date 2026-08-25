// ignore_for_file: avoid_implementing_value_types, inference_failure_on_function_invocation

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/core/clients/remote/http/http_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockHttpClient extends Mock implements HttpClient {}

class MockAuthInterceptor extends Mock implements HttpAuthInterceptor {}

class MockInternetClient extends Mock implements InternetClient {}

class MockLocalStorageClient extends Mock implements LocalStorageClient {}

class MockSupabaseDatabaseClient extends Mock
    implements SupabaseDatabaseClient {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockNavigatorStateGlobalKey extends Mock
    implements GlobalKey<NavigatorState> {}

class _FakePageRouteInfo extends Fake implements PageRouteInfo<dynamic> {}

class MockNavigationClient extends Mock implements NavigationClient {
  MockNavigationClient() {
    try {
      registerFallbackValue(_FakePageRouteInfo());
    } catch (_) {}
    when(() => navigatorKey).thenReturn(MockNavigatorStateGlobalKey());
    when(() => replaceAllRoute(any())).thenAnswer((_) async {});
    when(() => pushRoute<dynamic>(any())).thenAnswer((_) async => null);
    when(() => pushRoute<void>(any())).thenAnswer((_) async {});
    when(() => maybePop<Object?>(any())).thenAnswer((_) async => true);
    when(() => maybePop<Object?>()).thenAnswer((_) async => true);
    when(() => maybePop<dynamic>(any())).thenAnswer((_) async => true);
    when(() => maybePop<dynamic>()).thenAnswer((_) async => true);
  }
}

class MockStorageClient extends Mock implements StorageClient {}

class MockOfflineTracker extends Mock implements OfflineTracker {}

class MockSupabaseRealtimeClient extends Mock implements SupabaseRealtimeClient {}
