import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/work_order_checklist/work_order_checklist_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/work_order_bottom_actions.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';

import '../../../../../../../testing/mocks/factories/checklist_factory.dart';
import '../../../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../../../testing/mocks/factories/work_order_factory.dart';

class MockWorkOrdersCubit extends MockCubit<WorkOrdersState>
    implements WorkOrdersCubit {}

class MockPauseWorkflowCubit extends MockCubit<PauseWorkflowState>
    implements PauseWorkflowCubit {}

class MockUsersCubit extends MockCubit<UsersState> implements UsersCubit {}

class MockWorkOrderChecklistCubit extends MockCubit<WorkOrderChecklistState>
    implements WorkOrderChecklistCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockWorkOrdersCubit mockWorkOrdersCubit;
  late MockPauseWorkflowCubit mockPauseWorkflowCubit;
  late MockUsersCubit mockUsersCubit;
  late MockWorkOrderChecklistCubit mockChecklistCubit;
  late MockSessionCubit mockSessionCubit;

  setUpAll(() {
    registerFallbackValue(
      const ActionPermission.workOrderSubAction(
        WorkOrderSubAction.managePendingRequests,
      ),
    );
  });

  setUp(() {
    mockWorkOrdersCubit = MockWorkOrdersCubit();
    mockPauseWorkflowCubit = MockPauseWorkflowCubit();
    mockUsersCubit = MockUsersCubit();
    mockChecklistCubit = MockWorkOrderChecklistCubit();
    mockSessionCubit = MockSessionCubit();

    when(
      () => mockWorkOrdersCubit.state,
    ).thenReturn(const WorkOrdersState.initial());
    when(
      () => mockWorkOrdersCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      () => mockPauseWorkflowCubit.state,
    ).thenReturn(const PauseWorkflowState.initial());
    when(
      () => mockPauseWorkflowCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(false);

    when(() => mockSessionCubit.state).thenReturn(
      SessionState.initial().copyWith(
        user: UserFactory.makeUserProfileEntity(),
      ),
    );
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());

    when(
      () => mockChecklistCubit.state,
    ).thenReturn(const WorkOrderChecklistState.initial());
    when(
      () => mockChecklistCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestableWidget(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WorkOrdersCubit>.value(value: mockWorkOrdersCubit),
        BlocProvider<PauseWorkflowCubit>.value(value: mockPauseWorkflowCubit),
        BlocProvider<UsersCubit>.value(value: mockUsersCubit),
        BlocProvider<SessionCubit>.value(value: mockSessionCubit),
        BlocProvider<WorkOrderChecklistCubit>.value(value: mockChecklistCubit),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('WorkOrderBottomActions', () {
    testWidgets('disables conclusion while required checklist items pend', (
      tester,
    ) async {
      when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
      final item = ChecklistFactory.makeChecklistItemEntity().copyWith(
        isRequired: true,
      );
      when(
        () => mockChecklistCubit.state,
      ).thenReturn(WorkOrderChecklistState(items: [item], answers: const {}));
      final workOrder = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        status: WorkOrderStatus.inProgress,
      );

      await tester.pumpWidget(
        buildTestableWidget(WorkOrderBottomActions(workOrder: workOrder)),
      );

      final button = tester.widget<BaseButton>(
        find.widgetWithText(BaseButton, 'Concluir'),
      );
      expect(button.onTap, isNull);
    });

    testWidgets('enables conclusion when the work order has no checklist', (
      tester,
    ) async {
      when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
      final workOrder = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        status: WorkOrderStatus.inProgress,
        annulChecklistTemplateId: true,
      );

      await tester.pumpWidget(
        buildTestableWidget(WorkOrderBottomActions(workOrder: workOrder)),
      );

      final button = tester.widget<BaseButton>(
        find.widgetWithText(BaseButton, 'Concluir'),
      );
      expect(button.onTap, isNotNull);
    });

    testWidgets('renders Iniciar trabalho when status is open', (tester) async {
      final workOrder = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        status: WorkOrderStatus.open,
      );

      await tester.pumpWidget(
        buildTestableWidget(WorkOrderBottomActions(workOrder: workOrder)),
      );

      expect(find.text('Iniciar trabalho'), findsOneWidget);
    });

    testWidgets('renders Retomar trabalho when status is onHold', (
      tester,
    ) async {
      final workOrder = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        status: WorkOrderStatus.onHold,
      );

      await tester.pumpWidget(
        buildTestableWidget(WorkOrderBottomActions(workOrder: workOrder)),
      );

      expect(find.text('Retomar trabalho'), findsOneWidget);
    });

    testWidgets(
      'renders Pausar and Solicitar conclusão when inProgress and user has no manage permission',
      (tester) async {
        final workOrder = WorkOrderFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.inProgress,
        );

        await tester.pumpWidget(
          buildTestableWidget(WorkOrderBottomActions(workOrder: workOrder)),
        );

        expect(find.text('Pausar'), findsOneWidget);
        expect(find.text('Solicitar conclusão'), findsOneWidget);
      },
    );

    testWidgets(
      'renders Concluir when inProgress and user has manage permission',
      (tester) async {
        when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
        final workOrder = WorkOrderFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.inProgress,
        );

        await tester.pumpWidget(
          buildTestableWidget(WorkOrderBottomActions(workOrder: workOrder)),
        );

        expect(find.text('Pausar'), findsOneWidget);
        expect(find.text('Concluir'), findsOneWidget);
      },
    );

    testWidgets('renders nothing when status is completed', (tester) async {
      final workOrder = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        status: WorkOrderStatus.completed,
      );

      await tester.pumpWidget(
        buildTestableWidget(WorkOrderBottomActions(workOrder: workOrder)),
      );

      expect(find.text('Iniciar trabalho'), findsNothing);
      expect(find.text('Pausar'), findsNothing);
      expect(find.text('Retomar trabalho'), findsNothing);
    });
  });
}
