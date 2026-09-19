import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/company/data/data_sources/company_local_data_source.dart';
import 'package:o_jogo_da_obra/features/company/data/data_sources/company_remote_data_source.dart';

class MockCompanyRemoteDataSource extends Mock
    implements CompanyRemoteDataSource {}

class MockCompanyLocalDataSource extends Mock
    implements CompanyLocalDataSource {}
