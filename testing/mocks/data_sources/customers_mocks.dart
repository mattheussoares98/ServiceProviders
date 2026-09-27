import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/customers/data/data_sources/customers_local_data_source.dart';
import 'package:o_jogo_da_obra/features/customers/data/data_sources/customers_remote_data_source.dart';

class MockCustomersRemoteDataSource extends Mock
    implements CustomersRemoteDataSource {}

class MockCustomersLocalDataSource extends Mock
    implements CustomersLocalDataSource {}
