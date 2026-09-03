import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_history/work_order_history_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_history/work_order_history_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  late MockGetWorkOrderHistoryUseCase mockGetWorkOrderHistory;
  late MockNavigationClient mockNavigationClient;
  late WorkOrderHistoryCubitUseCases cubitUseCases;
  late String testWorkOrderId;

  setUp(() {
    mockGetWorkOrderHistory = MockGetWorkOrderHistoryUseCase();
    mockNavigationClient = MockNavigationClient();
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    cubitUseCases = WorkOrderHistoryCubitUseCases(
      getWorkOrderHistory: mockGetWorkOrderHistory,
    );
    testWorkOrderId = faker.guid.guid();
  });

  tearDown(GetIt.I.reset);

  group('WorkOrderHistoryCubit', () {
    test('initial state has idle load section and empty history', () {
      final cubit = WorkOrderHistoryCubit(useCases: cubitUseCases);
      expect(cubit.state.section(BaseSections.load).status, SectionStatus.idle);
      expect(cubit.state.history, isEmpty);
      expect(cubit.state.startDate, isNull);
      expect(cubit.state.endDate, isNull);
      cubit.close();
    });

    blocTest<WorkOrderHistoryCubit, WorkOrderHistoryState>(
      'emits [running, success] when loadHistory succeeds',
      build: () {
        when(() => mockGetWorkOrderHistory.call(any())).thenAnswer(
          (_) async => SuccessState(
            data: EntityFactory.makeAuditLogEntityList(),
          ),
        );
        return WorkOrderHistoryCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.loadHistory(testWorkOrderId),
      expect: () => [
        isA<WorkOrderHistoryState>().having(
          (s) => s.section(BaseSections.load).status,
          'load status',
          SectionStatus.running,
        ),
        isA<WorkOrderHistoryState>()
            .having(
              (s) => s.section(BaseSections.load).status,
              'load status',
              SectionStatus.success,
            )
            .having((s) => s.history.length, 'history.length', 3),
      ],
    );

    blocTest<WorkOrderHistoryCubit, WorkOrderHistoryState>(
      'loadHistory emits [running, error] when use case fails',
      build: () {
        when(() => mockGetWorkOrderHistory.call(any())).thenAnswer(
          (_) async => FailureState(message: 'Failed to load'),
        );
        return WorkOrderHistoryCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.loadHistory(testWorkOrderId),
      expect: () => [
        isA<WorkOrderHistoryState>().having(
          (s) => s.section(BaseSections.load).status,
          'load status',
          SectionStatus.running,
        ),
        isA<WorkOrderHistoryState>().having(
          (s) => s.section(BaseSections.load).status,
          'load status',
          SectionStatus.error,
        ),
      ],
    );

    test('setDateRange and clearDateFilter update state and filteredHistory correctly', () {
      final cubit = WorkOrderHistoryCubit(useCases: cubitUseCases);

      final date1 = DateTime(2026, 3, 1, 10);
      final date2 = DateTime(2026, 3, 5, 12);
      final date3 = DateTime(2026, 3, 10, 15);

      final baseHistory = [
        EntityFactory.makeAuditLogEntity().copyWith(createdAt: date1),
        EntityFactory.makeAuditLogEntity().copyWith(createdAt: date2),
        EntityFactory.makeAuditLogEntity().copyWith(createdAt: date3),
      ];

      cubit.emit(cubit.state.copyWith(history: baseHistory));
      expect(cubit.state.filteredHistory.length, 3);

      // Filter within date2 only
      cubit.setDateRange(
        startDate: DateTime(2026, 3, 4),
        endDate: DateTime(2026, 3, 6),
      );

      expect(cubit.state.startDate, DateTime(2026, 3, 4));
      expect(cubit.state.endDate, DateTime(2026, 3, 6));
      expect(cubit.state.filteredHistory.length, 1);
      expect(cubit.state.filteredHistory.first.createdAt, date2);

      // Clear filter
      cubit.clearDateFilter();
      expect(cubit.state.startDate, isNull);
      expect(cubit.state.endDate, isNull);
      expect(cubit.state.filteredHistory.length, 3);

      cubit.close();
    });
  });
}
