import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/users/data/data_sources/users_local_data_source.dart';
import 'package:o_jogo_da_obra/features/users/data/data_sources/users_remote_data_source.dart';

class MockUsersRemoteDataSource extends Mock implements UsersRemoteDataSource {}

class MockUsersLocalDataSource extends Mock implements UsersLocalDataSource {}
