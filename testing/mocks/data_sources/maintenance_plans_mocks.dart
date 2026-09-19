import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/data_sources/maintenance_plans_local_data_source.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/data_sources/maintenance_plans_remote_data_source.dart';

class MockMaintenancePlansRemoteDataSource extends Mock
    implements MaintenancePlansRemoteDataSource {}

class MockMaintenancePlansLocalDataSource extends Mock
    implements MaintenancePlansLocalDataSource {}
