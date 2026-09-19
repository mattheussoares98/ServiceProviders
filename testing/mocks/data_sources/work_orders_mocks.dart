import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/pause_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/pause_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_realtime_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';

class MockWorkOrdersRemoteDataSource extends Mock
    implements WorkOrdersRemoteDataSource {}

class MockWorkOrdersLocalDataSource extends Mock
    implements WorkOrdersLocalDataSource {}

class MockPauseRemoteDataSource extends Mock implements PauseRemoteDataSource {}

class MockPauseLocalDataSource extends Mock implements PauseLocalDataSource {}

class MockWorkOrderObservationsRemoteDataSource extends Mock
    implements WorkOrderObservationsRemoteDataSource {}

class MockWorkOrderObservationsLocalDataSource extends Mock
    implements WorkOrderObservationsLocalDataSource {}

class MockWorkOrdersRealtimeRemoteDataSource extends Mock
    implements WorkOrdersRealtimeRemoteDataSource {}
