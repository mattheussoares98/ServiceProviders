import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/assets/data/data_sources/assets_local_data_source.dart';
import 'package:o_jogo_da_obra/features/assets/data/data_sources/assets_remote_data_source.dart';

class MockAssetsRemoteDataSource extends Mock
    implements AssetsRemoteDataSource {}

class MockAssetsLocalDataSource extends Mock implements AssetsLocalDataSource {}
