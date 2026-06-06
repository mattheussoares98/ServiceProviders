import 'package:clean_architecture/features/assets/data/data_sources/assets_local_data_source.dart';
import 'package:clean_architecture/features/assets/data/data_sources/assets_remote_data_source.dart';
import 'package:clean_architecture/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:clean_architecture/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:clean_architecture/features/auth/data/data_sources/session_local_data_source.dart';
import 'package:clean_architecture/features/categories/data/data_sources/categories_local_data_source.dart';
import 'package:clean_architecture/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:clean_architecture/features/company/data/data_sources/company_local_data_source.dart';
import 'package:clean_architecture/features/company/data/data_sources/company_remote_data_source.dart';
import 'package:clean_architecture/features/locations/data/data_sources/locations_local_data_source.dart';
import 'package:clean_architecture/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockSessionLocalDataSource extends Mock
    implements SessionLocalDataSource {}

class MockCompanyRemoteDataSource extends Mock
    implements CompanyRemoteDataSource {}

class MockCompanyLocalDataSource extends Mock
    implements CompanyLocalDataSource {}

class MockCategoriesRemoteDataSource extends Mock
    implements CategoriesRemoteDataSource {}

class MockCategoriesLocalDataSource extends Mock
    implements CategoriesLocalDataSource {}

class MockLocationsRemoteDataSource extends Mock
    implements LocationsRemoteDataSource {}

class MockLocationsLocalDataSource extends Mock
    implements LocationsLocalDataSource {}

class MockAssetsRemoteDataSource extends Mock
    implements AssetsRemoteDataSource {}

class MockAssetsLocalDataSource extends Mock implements AssetsLocalDataSource {}
