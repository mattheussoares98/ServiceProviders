import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/work_order_checklist/work_order_checklist_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/work_order_checklist_section.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../../testing/mocks/factories/checklist_factory.dart';
import '../../../../../../../testing/mocks/factories/work_order_factory.dart';

class MockWorkOrderChecklistCubit extends MockCubit<WorkOrderChecklistState>
    implements WorkOrderChecklistCubit {}

void main() {
  late MockWorkOrderChecklistCubit mockCubit;

  setUp(() {
    mockCubit = MockWorkOrderChecklistCubit();
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildWidget({required bool hasTemplate, WorkOrderStatus? status}) {
    var workOrder = WorkOrderFactory.makeWorkOrderEntity();
    if (!hasTemplate) {
      workOrder = workOrder.copyWith(annulChecklistTemplateId: true);
    }
    if (status != null) {
      workOrder = workOrder.copyWith(status: status);
    }

    return MaterialApp(
      home: BlocProvider<WorkOrderChecklistCubit>.value(
        value: mockCubit,
        child: Scaffold(
          body: CustomScrollView(
            slivers: [WorkOrderChecklistSection(workOrder: workOrder)],
          ),
        ),
      ),
    );
  }

  void stubLoaded(
    List<ChecklistItemEntity> items, {
    Map<String, ChecklistAnswerEntity> answers = const {},
  }) {
    when(() => mockCubit.state).thenReturn(
      WorkOrderChecklistState(
        items: items,
        answers: answers,
        sections: const {BaseSections.load: SectionState.success()},
      ),
    );
  }

  testWidgets('renders nothing when the work order has no checklist', (
    tester,
  ) async {
    stubLoaded(const []);

    await tester.pumpWidget(buildWidget(hasTemplate: false));

    expect(find.text('Checklist'), findsNothing);
  });

  testWidgets('renders the items and the answered counter', (tester) async {
    final items = [
      ChecklistFactory.makeChecklistItemEntity().copyWith(
        type: ChecklistItemType.boolean,
        isRequired: true,
      ),
      ChecklistFactory.makeChecklistItemEntity().copyWith(
        type: ChecklistItemType.boolean,
        isRequired: false,
      ),
    ];
    stubLoaded(
      items,
      answers: {
        items.first.id: ChecklistAnswerEntity.empty(
          checklistItemId: items.first.id,
        ).copyWith(booleanValue: true),
      },
    );

    await tester.pumpWidget(
      buildWidget(hasTemplate: true, status: WorkOrderStatus.inProgress),
    );

    expect(find.text('Checklist'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    // Items are not rendered on the main page directly
    for (final item in items) {
      expect(find.text(item.label), findsNothing);
    }

    // Tapping the card opens the modal with the checklist items
    await tester.tap(find.text('Checklist'));
    await tester.pumpAndSettle();

    for (final item in items) {
      expect(find.text(item.label), findsOneWidget);
    }
  });

  testWidgets('warns while a required item is unanswered', (tester) async {
    final item = ChecklistFactory.makeChecklistItemEntity().copyWith(
      type: ChecklistItemType.boolean,
      isRequired: true,
    );
    stubLoaded([item]);

    await tester.pumpWidget(
      buildWidget(hasTemplate: true, status: WorkOrderStatus.inProgress),
    );

    expect(find.text('Há itens obrigatórios pendentes'), findsOneWidget);
  });

  testWidgets('shows the empty message when the template has no items', (
    tester,
  ) async {
    stubLoaded(const []);

    await tester.pumpWidget(
      buildWidget(hasTemplate: true, status: WorkOrderStatus.inProgress),
    );

    expect(
      find.text('O checklist desta ordem não possui itens'),
      findsOneWidget,
    );
  });
}
