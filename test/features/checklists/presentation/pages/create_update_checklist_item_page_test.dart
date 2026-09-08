import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/pages/create_update_checklist_item/create_update_checklist_item_page.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';

import '../../../../../testing/mocks/factories/checklist_factory.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';

class MockChecklistTemplatesCubit extends MockCubit<ChecklistTemplatesState>
    implements ChecklistTemplatesCubit {}

class MockUsersCubit extends MockCubit<UsersState> implements UsersCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockChecklistTemplatesCubit mockCubit;
  late MockUsersCubit mockUsersCubit;
  late MockSessionCubit mockSessionCubit;

  setUpAll(() {
    registerFallbackValue(
      const ActionPermission.resource(
        resourceType: ResourceType.checklists,
        permissionAction: PermissionAction.read,
      ),
    );
    registerFallbackValue(ChecklistItemType.boolean);
  });

  setUp(() {
    mockCubit = MockChecklistTemplatesCubit();
    mockUsersCubit = MockUsersCubit();
    mockSessionCubit = MockSessionCubit();

    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockCubit.state,
    ).thenReturn(const ChecklistTemplatesState.initial());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
    when(() => mockSessionCubit.state).thenReturn(
      SessionState(user: UserFactory.makeUserProfileEntity(), isLoggedIn: true),
    );
    when(
      () => mockCubit.saveItem(
        id: any(named: 'id'),
        templateId: any(named: 'templateId'),
        label: any(named: 'label'),
        type: any(named: 'type'),
        isRequired: any(named: 'isRequired'),
        options: any(named: 'options'),
        sortOrder: any(named: 'sortOrder'),
        createdAt: any(named: 'createdAt'),
      ),
    ).thenAnswer((_) async => true);
  });

  Widget buildWidget({ChecklistItemEntity? item, required String templateId}) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ChecklistTemplatesCubit>.value(value: mockCubit),
          BlocProvider<UsersCubit>.value(value: mockUsersCubit),
          BlocProvider<SessionCubit>.value(value: mockSessionCubit),
        ],
        child: CreateUpdateChecklistItemPage(
          templateId: templateId,
          item: item,
          sortOrder: 2,
        ),
      ),
    );
  }

  testWidgets('shows the creation title and no options field by default', (
    tester,
  ) async {
    final item = ChecklistFactory.makeChecklistItemEntity();

    await tester.pumpWidget(buildWidget(templateId: item.templateId));

    expect(find.text('Criando item'), findsOneWidget);
    expect(find.text('Opções *'), findsNothing);
  });

  testWidgets('prefills the fields when editing an existing item', (
    tester,
  ) async {
    final item = ChecklistFactory.makeChecklistItemEntity().copyWith(
      type: ChecklistItemType.text,
      isRequired: true,
      annulOptions: true,
    );

    await tester.pumpWidget(
      buildWidget(item: item, templateId: item.templateId),
    );

    expect(find.text('Editando item'), findsOneWidget);
    expect(find.text(item.label), findsOneWidget);
  });

  testWidgets('saves the item with the typed label and sort order', (
    tester,
  ) async {
    final item = ChecklistFactory.makeChecklistItemEntity().copyWith(
      type: ChecklistItemType.boolean,
      annulOptions: true,
    );

    await tester.pumpWidget(
      buildWidget(item: item, templateId: item.templateId),
    );
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    final capturedOptions = verify(
      () => mockCubit.saveItem(
        id: item.id,
        templateId: item.templateId,
        label: item.label,
        type: ChecklistItemType.boolean,
        isRequired: item.isRequired,
        options: captureAny(named: 'options'),
        sortOrder: 2,
        createdAt: item.createdAt,
      ),
    ).captured.single;

    // A non-selection item must not carry options.
    expect(capturedOptions, isNull);
  });

  testWidgets('requires at least one option for a selection item', (
    tester,
  ) async {
    final item = ChecklistFactory.makeChecklistItemEntity().copyWith(
      type: ChecklistItemType.selection,
      options: const [],
    );

    await tester.pumpWidget(
      buildWidget(item: item, templateId: item.templateId),
    );

    expect(find.text('Informe ao menos uma opção'), findsOneWidget);

    await tester.tap(find.text('Salvar'));
    await tester.pump();

    verifyNever(
      () => mockCubit.saveItem(
        id: any(named: 'id'),
        templateId: any(named: 'templateId'),
        label: any(named: 'label'),
        type: any(named: 'type'),
        isRequired: any(named: 'isRequired'),
        options: any(named: 'options'),
        sortOrder: any(named: 'sortOrder'),
        createdAt: any(named: 'createdAt'),
      ),
    );
  });
}
