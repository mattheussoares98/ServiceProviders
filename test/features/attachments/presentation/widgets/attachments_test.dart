import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachments.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';

import '../../../../../testing/mocks/entity_factory.dart';

class MockAttachmentsCubit extends MockCubit<AttachmentsState>
    implements AttachmentsCubit {}

class MockUsersCubit extends MockCubit<UsersState> implements UsersCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

const _createAttachment = ActionPermission.resource(
  resourceType: ResourceType.attachments,
  permissionAction: PermissionAction.create,
);

const _deleteAttachment = ActionPermission.resource(
  resourceType: ResourceType.attachments,
  permissionAction: PermissionAction.delete,
);

void main() {
  late MockAttachmentsCubit mockAttachmentsCubit;
  late MockUsersCubit mockUsersCubit;
  late MockSessionCubit mockSessionCubit;

  /// A document attachment renders `_DocumentPreview`, which paints an icon
  /// instead of decoding a file — an image preview would fail to resolve its
  /// fake path under the test binding.
  AttachmentEntity documentAttachment() =>
      EntityFactory.makeAttachmentEntity().copyWith(
        fileType: FileType.pdf,
        fileName: 'relatorio.pdf',
        uploadStatus: UploadStatus.uploaded,
      );

  void arrangeState({List<AttachmentEntity> attachments = const []}) {
    when(() => mockAttachmentsCubit.state).thenReturn(
      AttachmentsState(status: StateStatus.loaded, attachments: attachments),
    );
  }

  /// Grants exactly the listed permissions and denies everything else.
  void arrangePermissions(Set<ActionPermission> granted) {
    when(() => mockUsersCubit.hasPermission(any()))
        .thenAnswer((invocation) => granted.contains(
              invocation.positionalArguments.first as ActionPermission,
            ));
  }

  setUpAll(() {
    registerFallbackValue(_createAttachment);
  });

  setUp(() {
    mockAttachmentsCubit = MockAttachmentsCubit();
    mockUsersCubit = MockUsersCubit();
    mockSessionCubit = MockSessionCubit();

    when(() => mockAttachmentsCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSessionCubit.state).thenReturn(
      SessionState.initial().copyWith(
        user: EntityFactory.makeUserProfileEntity(),
      ),
    );
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());

    arrangeState();
    arrangePermissions({_createAttachment, _deleteAttachment});
  });

  Future<void> pumpAttachments(
    WidgetTester tester, {
    required bool isWorkOrderActive,
  }) {
    return tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AttachmentsCubit>.value(value: mockAttachmentsCubit),
          BlocProvider<UsersCubit>.value(value: mockUsersCubit),
          BlocProvider<SessionCubit>.value(value: mockSessionCubit),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [Attachments(isWorkOrderActive: isWorkOrderActive)],
            ),
          ),
        ),
      ),
    );
  }

  group('Attachments', () {
    testWidgets('shows Adicionar while the work order is active', (tester) async {
      await pumpAttachments(tester, isWorkOrderActive: true);

      expect(find.text('Adicionar'), findsOneWidget);
    });

    testWidgets('hides Adicionar once the work order stops accepting evidence', (
      tester,
    ) async {
      await pumpAttachments(tester, isWorkOrderActive: false);

      expect(find.text('Adicionar'), findsNothing);
    });

    testWidgets('hides Adicionar without attachments.create', (tester) async {
      arrangePermissions({_deleteAttachment});

      await pumpAttachments(tester, isWorkOrderActive: true);

      expect(find.text('Adicionar'), findsNothing);
    });

    testWidgets('empty state is not tappable without attachments.create', (
      tester,
    ) async {
      arrangePermissions({});

      await pumpAttachments(tester, isWorkOrderActive: true);

      expect(find.text('Nenhum anexo adicionado'), findsOneWidget);
      final inkWell = tester.widget<InkWell>(
        find.ancestor(
          of: find.text('Nenhum anexo adicionado'),
          matching: find.byType(InkWell),
        ),
      );
      expect(inkWell.onTap, isNull);
    });

    testWidgets('shows Remover anexo with attachments.delete', (tester) async {
      arrangeState(attachments: [documentAttachment()]);

      await pumpAttachments(tester, isWorkOrderActive: true);

      expect(find.text('Remover anexo'), findsOneWidget);
    });

    testWidgets('hides Remover anexo without attachments.delete', (tester) async {
      arrangeState(attachments: [documentAttachment()]);
      arrangePermissions({_createAttachment});

      await pumpAttachments(tester, isWorkOrderActive: true);

      expect(find.text('Remover anexo'), findsNothing);
      // Adding and deleting are independent: a provider adds but never deletes.
      expect(find.text('Adicionar'), findsOneWidget);
    });

    testWidgets('keeps Remover anexo on a closed work order', (tester) async {
      arrangeState(attachments: [documentAttachment()]);

      await pumpAttachments(tester, isWorkOrderActive: false);

      // The status gate freezes additions only; the contracting company can
      // still clean up evidence after the fact.
      expect(find.text('Remover anexo'), findsOneWidget);
    });

    testWidgets('renders safely when attachment fileSizeBytes is null', (
      tester,
    ) async {
      arrangeState(
        attachments: [documentAttachment().copyWith(annulFileSizeBytes: true)],
      );

      await pumpAttachments(tester, isWorkOrderActive: true);

      expect(find.text('Remover anexo'), findsOneWidget);
    });
  });
}
