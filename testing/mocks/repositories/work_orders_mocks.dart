import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_order_observations_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';

class MockWorkOrdersRepository extends Mock implements WorkOrdersRepository {}

class MockPauseRepository extends Mock implements PauseRepository {}

class MockWorkOrderObservationsRepository extends Mock
    implements WorkOrderObservationsRepository {}
