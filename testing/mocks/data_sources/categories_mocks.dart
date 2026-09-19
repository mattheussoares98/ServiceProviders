import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/categories/data/data_sources/categories_local_data_source.dart';
import 'package:o_jogo_da_obra/features/categories/data/data_sources/categories_remote_data_source.dart';

class MockCategoriesRemoteDataSource extends Mock
    implements CategoriesRemoteDataSource {}

class MockCategoriesLocalDataSource extends Mock
    implements CategoriesLocalDataSource {}
