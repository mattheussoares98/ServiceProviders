import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/sync/data/data_sources/sync_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sync/data/data_sources/sync_remote_data_source.dart';

class MockSyncLocalDataSource extends Mock implements SyncLocalDataSource {}

class MockSyncRemoteDataSource extends Mock implements SyncRemoteDataSource {}
