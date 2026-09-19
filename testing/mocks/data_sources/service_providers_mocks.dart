import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/data_sources/service_provider_local_data_source.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/data_sources/service_provider_remote_data_source.dart';

class MockServiceProviderRemoteDataSource extends Mock
    implements ServiceProviderRemoteDataSource {}

class MockServiceProviderLocalDataSource extends Mock
    implements ServiceProviderLocalDataSource {}
