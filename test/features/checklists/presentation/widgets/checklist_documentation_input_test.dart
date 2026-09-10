import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/work_order_checklist/work_order_checklist_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/widgets/checklist_item_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';

import '../../../../../testing/mocks/factories/checklist_factory.dart';

class MockWorkOrderChecklistCubit extends MockCubit<WorkOrderChecklistState>
    implements WorkOrderChecklistCubit {}

class MockAttachmentsCubit extends MockCubit<AttachmentsState>
    implements AttachmentsCubit {}

void main() {
  late MockWorkOrderChecklistCubit mockChecklistCubit;
  late MockAttachmentsCubit mockAttachmentsCubit;

  setUpAll(() {
    registerFallbackValue(AttachmentEntity.empty(fileName: 'report.pdf'));
    registerFallbackValue(AttachmentSource.document);
  });

  setUp(() {
    mockChecklistCubit = MockWorkOrderChecklistCubit();
    mockAttachmentsCubit = MockAttachmentsCubit();

    when(
      () => mockChecklistCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockChecklistCubit.state,
    ).thenReturn(const WorkOrderChecklistState.initial());
    when(
      () => mockAttachmentsCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockAttachmentsCubit.state).thenReturn(const AttachmentsState());
    when(
      () => mockAttachmentsCubit.openAttachment(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockAttachmentsCubit.refreshAttachments(),
    ).thenAnswer((_) async {});
  });

  Widget buildWidget({ChecklistAnswerEntity? response}) {
    final item = ChecklistFactory.makeChecklistItemEntity().copyWith(
      type: ChecklistItemType.documentation,
    );

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<WorkOrderChecklistCubit>.value(
            value: mockChecklistCubit,
          ),
          BlocProvider<AttachmentsCubit>.value(value: mockAttachmentsCubit),
        ],
        child: Scaffold(
          body: ChecklistDocumentationInput(
            item: item,
            workOrderId: 'wo-1',
            response: response,
            onChanged: (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('displays empty label when no document is attached', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());

    expect(find.text('Anexar documento'), findsOneWidget);
    expect(find.text('Substituir'), findsNothing);
  });

  testWidgets('displays document name and opens document when tapped', (
    tester,
  ) async {
    final answer = ChecklistFactory.makeChecklistAnswerEntity().copyWith(
      photoUrl: 'https://example.com/files/inspecao_relatorio.pdf',
    );

    await tester.pumpWidget(buildWidget(response: answer));

    expect(find.text('inspecao_relatorio.pdf'), findsOneWidget);
    expect(find.text('Documento anexado'), findsOneWidget);
    expect(find.text('Substituir'), findsOneWidget);

    await tester.tap(find.text('inspecao_relatorio.pdf'));
    await tester.pump();

    verify(() => mockAttachmentsCubit.openAttachment(any())).called(1);
  });

  testWidgets('displays LoadingCircle while uploading', (tester) async {
    when(
      () => mockChecklistCubit.attachEvidence(
        workOrderId: any(named: 'workOrderId'),
        checklistItemId: any(named: 'checklistItemId'),
        source: any(named: 'source'),
        allowedExtensions: any(named: 'allowedExtensions'),
      ),
    ).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return true;
    });

    await tester.pumpWidget(buildWidget());

    expect(find.text('Anexar documento'), findsOneWidget);
    expect(find.text('Enviando...'), findsNothing);

    await tester.tap(find.text('Anexar documento'));
    await tester.pump();

    expect(find.text('Enviando...'), findsOneWidget);
    expect(find.byType(LoadingCircle), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Enviando...'), findsNothing);
  });
}
