import 'package:clean_architecture/features/assets/data/data_sources/assets_local_data_source.dart';
import 'package:clean_architecture/features/assets/data/data_sources/assets_remote_data_source.dart';
import 'package:clean_architecture/features/attachments/data/data_sources/attachments_local_data_source.dart';
import 'package:clean_architecture/features/attachments/data/data_sources/attachments_remote_data_source.dart';
import 'package:clean_architecture/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:clean_architecture/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:clean_architecture/features/auth/data/data_sources/session_local_data_source.dart';
import 'package:clean_architecture/features/categories/data/data_sources/categories_local_data_source.dart';
import 'package:clean_architecture/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:clean_architecture/features/checklists/data/data_sources/checklists_local_data_source.dart';
import 'package:clean_architecture/features/checklists/data/data_sources/checklists_remote_data_source.dart';
import 'package:clean_architecture/features/company/data/data_sources/company_local_data_source.dart';
import 'package:clean_architecture/features/company/data/data_sources/company_remote_data_source.dart';
import 'package:clean_architecture/features/locations/data/data_sources/locations_local_data_source.dart';
import 'package:clean_architecture/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:clean_architecture/features/maintenance_plans/data/data_sources/maintenance_plans_local_data_source.dart';
import 'package:clean_architecture/features/maintenance_plans/data/data_sources/maintenance_plans_remote_data_source.dart';
import 'package:clean_architecture/features/users/data/data_sources/users_local_data_source.dart';
import 'package:clean_architecture/features/users/data/data_sources/users_remote_data_source.dart';
import 'package:clean_architecture/features/work_orders/data/data_sources/work_orders_local_data_source.dart';
import 'package:clean_architecture/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';
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

class MockWorkOrdersRemoteDataSource extends Mock
    implements WorkOrdersRemoteDataSource {}

class MockWorkOrdersLocalDataSource extends Mock
    implements WorkOrdersLocalDataSource {}

class MockChecklistsRemoteDataSource extends Mock
    implements ChecklistsRemoteDataSource {}

class MockChecklistsLocalDataSource extends Mock
    implements ChecklistsLocalDataSource {}

class MockMaintenancePlansRemoteDataSource extends Mock
    implements MaintenancePlansRemoteDataSource {}

class MockMaintenancePlansLocalDataSource extends Mock
    implements MaintenancePlansLocalDataSource {}

class MockAttachmentsRemoteDataSource extends Mock
    implements AttachmentsRemoteDataSource {}

class MockAttachmentsLocalDataSource extends Mock
    implements AttachmentsLocalDataSource {}

class MockUsersRemoteDataSource extends Mock implements UsersRemoteDataSource {}

class MockUsersLocalDataSource extends Mock implements UsersLocalDataSource {}
