import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/configurations/data/data_sources/configurations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/configurations/data/data_sources/configurations_remote_data_source.dart';

class MockConfigurationsRemoteDataSource extends Mock
    implements ConfigurationsRemoteDataSource {}

class MockConfigurationsLocalDataSource extends Mock
    implements ConfigurationsLocalDataSource {}
