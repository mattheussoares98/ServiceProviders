import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:clean_architecture/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockDioException extends Mock implements DioException {}

class MockInternetConnection extends Mock implements InternetConnection {}

class MockResponse<T> extends Mock implements Response<T> {}

class MockSupabaseAuthClient extends Mock implements SupabaseAuthClient {}

class MockSupabaseDatabaseClient extends Mock
    implements SupabaseDatabaseClient {}
