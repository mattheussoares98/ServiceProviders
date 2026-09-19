import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_remote_data_source.dart';

class MockLocationsRemoteDataSource extends Mock
    implements LocationsRemoteDataSource {}

class MockLocationsLocalDataSource extends Mock
    implements LocationsLocalDataSource {}
