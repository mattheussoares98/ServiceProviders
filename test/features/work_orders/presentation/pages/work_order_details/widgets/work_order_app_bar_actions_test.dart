import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_details/work_order_details_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/work_order_app_bar_actions.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';

import '../../../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../../../testing/mocks/factories/work_order_factory.dart';

class MockWorkOrderDetailsCubit extends Mock implements WorkOrderDetailsCubit {}

class MockUsersCubit extends Mock implements UsersCubit {}

class MockAttachmentsCubit extends Mock implements AttachmentsCubit {}

class MockSessionCubit extends Mock implements SessionCubit {}

void main() {
  late MockWorkOrderDetailsCubit mockDetailsCubit;
  late MockUsersCubit mockUsersCubit;
  late MockAttachmentsCubit mockAttachmentsCubit;
  late MockSessionCubit mockSessionCubit;

  setUpAll(() {
    registerFallbackValue(
      const ActionPermission.workOrderSubAction(
        WorkOrderSubAction.managePendingRequests,
      ),
    );
    registerFallbackValue(
      const ActionPermission.resource(
        resourceType: ResourceType.workOrders,
        permissionAction: PermissionAction.read,
      ),
    );
  });

  setUp(() {
    mockDetailsCubit = MockWorkOrderDetailsCubit();
    mockUsersCubit = MockUsersCubit();
    mockAttachmentsCubit = MockAttachmentsCubit();
    mockSessionCubit = MockSessionCubit();

    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);

    when(() => mockSessionCubit.state).thenReturn(
      SessionState.initial().copyWith(
        user: UserFactory.makeUserProfileEntity(),
      ),
    );
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestableWidget(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WorkOrderDetailsCubit>.value(value: mockDetailsCubit),
        BlocProvider<UsersCubit>.value(value: mockUsersCubit),
        BlocProvider<AttachmentsCubit>.value(value: mockAttachmentsCubit),
        BlocProvider<SessionCubit>.value(value: mockSessionCubit),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('EditAndDeleteIcons', () {
    testWidgets('shows edit button when work order is open or in progress', (
      tester,
    ) async {
      when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
      final workOrder = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        status: WorkOrderStatus.inProgress,
      );

      await tester.pumpWidget(
        buildTestableWidget(WorkOrderAppBarActions(workOrder: workOrder)),
      );

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Icon &&
              (w.icon == Icons.edit_outlined ||
                  w.icon == CupertinoIcons.pencil),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'hides edit button when work order is completed and user cannot manage pending requests',
      (tester) async {
        when(
          () => mockUsersCubit.hasPermission(
            const ActionPermission.workOrderSubAction(
              WorkOrderSubAction.managePendingRequests,
            ),
          ),
        ).thenReturn(false);
        final workOrder = WorkOrderFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.completed,
        );

        await tester.pumpWidget(
          buildTestableWidget(WorkOrderAppBarActions(workOrder: workOrder)),
        );

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Icon &&
                (w.icon == Icons.edit_outlined ||
                    w.icon == CupertinoIcons.pencil),
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'shows edit button when work order is completed but user has managePendingRequests permission',
      (tester) async {
        when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
        final workOrder = WorkOrderFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.completed,
        );

        await tester.pumpWidget(
          buildTestableWidget(WorkOrderAppBarActions(workOrder: workOrder)),
        );

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Icon &&
                (w.icon == Icons.edit_outlined ||
                    w.icon == CupertinoIcons.pencil),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
