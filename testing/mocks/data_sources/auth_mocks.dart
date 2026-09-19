import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:o_jogo_da_obra/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/auth/data/data_sources/session_local_data_source.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockSessionLocalDataSource extends Mock
    implements SessionLocalDataSource {}
