import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/calculate_work_order_kpis_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/delete_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_pause_requests_batch_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_provider_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_history_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_observations_batch_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/restore_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/resume_work_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/watch_pause_reasons_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/watch_pause_requests_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/watch_work_order_change_requests_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/watch_work_order_observations_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/watch_work_orders_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/work_order_observations_use_cases.dart';

class MockGetProviderWorkOrdersUseCase extends Mock
    implements GetProviderWorkOrdersUseCase {}

class MockWatchWorkOrdersRealtimeUseCase extends Mock
    implements WatchWorkOrdersRealtimeUseCase {}

class MockWatchWorkOrderChangeRequestsRealtimeUseCase extends Mock
    implements WatchWorkOrderChangeRequestsRealtimeUseCase {}

class MockWatchPauseReasonsRealtimeUseCase extends Mock
    implements WatchPauseReasonsRealtimeUseCase {}

class MockWatchPauseRequestsRealtimeUseCase extends Mock
    implements WatchPauseRequestsRealtimeUseCase {}

class MockCalculateWorkOrderKpisUseCase extends Mock
    implements CalculateWorkOrderKpisUseCase {}

class MockGetWorkOrderObservationsUseCase extends Mock
    implements GetWorkOrderObservationsUseCase {}

class MockCreateWorkOrderObservationUseCase extends Mock
    implements CreateWorkOrderObservationUseCase {}

class MockDeleteWorkOrderObservationUseCase extends Mock
    implements DeleteWorkOrderObservationUseCase {}

class MockWatchWorkOrderObservationsRealtimeUseCase extends Mock
    implements WatchWorkOrderObservationsRealtimeUseCase {}

class MockGetWorkOrderObservationsBatchUseCase extends Mock
    implements GetWorkOrderObservationsBatchUseCase {}

class MockGetPauseRequestsBatchUseCase extends Mock
    implements GetPauseRequestsBatchUseCase {}

class MockGetWorkOrderByIdUseCase extends Mock
    implements GetWorkOrderByIdUseCase {}

class MockUpdateWorkOrderUseCase extends Mock
    implements UpdateWorkOrderUseCase {}

class MockDeleteWorkOrderUseCase extends Mock
    implements DeleteWorkOrderUseCase {}

class MockRestoreWorkOrderUseCase extends Mock
    implements RestoreWorkOrderUseCase {}

class MockResumeWorkUseCase extends Mock implements ResumeWorkUseCase {}

class MockGetWorkOrderHistoryUseCase extends Mock
    implements GetWorkOrderHistoryUseCase {}

class MockCreateWorkOrderChangeRequestUseCase extends Mock
    implements CreateWorkOrderChangeRequestUseCase {}

class MockReviewWorkOrderChangeRequestUseCase extends Mock
    implements ReviewWorkOrderChangeRequestUseCase {}
