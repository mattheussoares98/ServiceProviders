// ignore_for_file: avoid_implementing_value_types, inference_failure_on_function_invocation

import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:clean_architecture/core/clients/remote/http/http_client.dart';
import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockHttpClient extends Mock implements HttpClient {}

class MockAuthInterceptor extends Mock implements HttpAuthInterceptor {}

class MockInternetClient extends Mock implements InternetClient {}

class MockLocalStorageClient extends Mock implements LocalStorageClient {}

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
