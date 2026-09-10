import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/domain/entities/file_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/work_order_checklist/work_order_checklist_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/widgets/checklist_item_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_image_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

import '../../../../../testing/mocks/factories/checklist_factory.dart';

class MockWorkOrderChecklistCubit extends MockCubit<WorkOrderChecklistState>
    implements WorkOrderChecklistCubit {}

class MockAttachmentsCubit extends MockCubit<AttachmentsState>
    implements AttachmentsCubit {}

void main() {
  late MockWorkOrderChecklistCubit mockChecklistCubit;
  late MockAttachmentsCubit mockAttachmentsCubit;

  setUpAll(() {
    registerFallbackValue(AttachmentSource.gallery);
  });

  setUp(() {
    mockChecklistCubit = MockWorkOrderChecklistCubit();
    mockAttachmentsCubit = MockAttachmentsCubit();

    when(() => mockChecklistCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockChecklistCubit.state)
        .thenReturn(const WorkOrderChecklistState.initial());
    when(() => mockAttachmentsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAttachmentsCubit.state).thenReturn(const AttachmentsState());
  });

  Widget buildWidget({ChecklistAnswerEntity? response}) {
    final item = ChecklistFactory.makeChecklistItemEntity().copyWith(
      type: ChecklistItemType.photo,
    );

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<WorkOrderChecklistCubit>.value(value: mockChecklistCubit),
          BlocProvider<AttachmentsCubit>.value(value: mockAttachmentsCubit),
        ],
        child: Scaffold(
          body: ChecklistPhotoInput(
            item: item,
            workOrderId: 'wo-1',
            response: response,
            onChanged: (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets(
    'on mobile: displays camera icon and opens bottom sheet with photo & gallery options',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await tester.pumpWidget(buildWidget());

        final platformIcon =
            tester.widget<PlatformIcon>(find.byType(PlatformIcon));
        expect(platformIcon.materialIcon, Icons.camera_alt_outlined);
        expect(platformIcon.cupertinoIcon, CupertinoIcons.camera);
        expect(find.text('Anexar foto'), findsOneWidget);

        await tester.tap(find.text('Anexar foto'));
        await tester.pumpAndSettle();

        expect(find.text('Tirar foto'), findsOneWidget);
        expect(find.text('Escolher da galeria'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets(
    'on non-mobile: displays photo library icon and directly triggers document pick with image allowedExtensions',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        when(
          () => mockChecklistCubit.attachEvidence(
            workOrderId: any(named: 'workOrderId'),
            checklistItemId: any(named: 'checklistItemId'),
            source: any(named: 'source'),
            allowedExtensions: any(named: 'allowedExtensions'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockAttachmentsCubit.refreshAttachments(),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(buildWidget());

        final platformIcon =
            tester.widget<PlatformIcon>(find.byType(PlatformIcon));
        expect(platformIcon.materialIcon, Icons.photo_library_outlined);
        expect(platformIcon.cupertinoIcon, CupertinoIcons.photo);
        expect(find.text('Anexar foto'), findsOneWidget);

        await tester.tap(find.text('Anexar foto'));
        await tester.pumpAndSettle();

        expect(find.text('Tirar foto'), findsNothing);
        verify(
          () => mockChecklistCubit.attachEvidence(
            workOrderId: 'wo-1',
            checklistItemId: any(named: 'checklistItemId'),
            source: AttachmentSource.document,
            allowedExtensions: FileExtension.images,
          ),
        ).called(1);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets(
    'displays BaseImageWidget preview and Substituir when photoUrl is present',
    (tester) async {
      final answer = ChecklistFactory.makeChecklistAnswerEntity().copyWith(
        photoUrl: 'https://example.com/evidence.jpg',
      );

      await tester.pumpWidget(buildWidget(response: answer));

      expect(find.byType(BaseImageWidget), findsOneWidget);
      expect(find.text('Foto anexada'), findsOneWidget);
      expect(find.text('Substituir'), findsOneWidget);
    },
  );
}
