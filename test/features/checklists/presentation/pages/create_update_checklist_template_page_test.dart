import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/pages/create_update_checklist_template/create_update_checklist_template_page.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';

import '../../../../../testing/mocks/factories/checklist_factory.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';

class MockChecklistTemplatesCubit extends MockCubit<ChecklistTemplatesState>
    implements ChecklistTemplatesCubit {}

class MockCategoriesCubit extends MockCubit<CategoriesState>
    implements CategoriesCubit {}

class MockUsersCubit extends MockCubit<UsersState> implements UsersCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockChecklistTemplatesCubit mockCubit;
  late MockCategoriesCubit mockCategoriesCubit;
  late MockUsersCubit mockUsersCubit;
  late MockSessionCubit mockSessionCubit;

  setUpAll(() {
    registerFallbackValue(
      const ActionPermission.resource(
        resourceType: ResourceType.checklists,
        permissionAction: PermissionAction.read,
      ),
    );
    registerFallbackValue(ChecklistFactory.makeChecklistTemplateEntity());
  });

  setUp(() {
    mockCubit = MockChecklistTemplatesCubit();
    mockCategoriesCubit = MockCategoriesCubit();
    mockUsersCubit = MockUsersCubit();
    mockSessionCubit = MockSessionCubit();

    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockCategoriesCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockCategoriesCubit.state,
    ).thenReturn(const CategoriesState.initial());
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
    when(() => mockSessionCubit.state).thenReturn(
      SessionState(user: UserFactory.makeUserProfileEntity(), isLoggedIn: true),
    );
    when(() => mockCubit.selectTemplate(any())).thenAnswer((_) async {});
    when(
      () => mockCubit.saveTemplate(
        id: any(named: 'id'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        categoryId: any(named: 'categoryId'),
        createdAt: any(named: 'createdAt'),
      ),
    ).thenAnswer((_) async => true);
  });

  void stubState({
    ChecklistTemplateEntity? selected,
    List<ChecklistItemEntity> items = const [],
  }) {
    when(() => mockCubit.state).thenReturn(
      ChecklistTemplatesState(
        templates: const [],
        templateItems: items,
        selectedTemplate: selected,
        sections: const {
          ChecklistTemplatesSections.loadItems: SectionState.success(),
        },
      ),
    );
  }

  Widget buildWidget({ChecklistTemplateEntity? template}) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ChecklistTemplatesCubit>.value(value: mockCubit),
          BlocProvider<CategoriesCubit>.value(value: mockCategoriesCubit),
          BlocProvider<UsersCubit>.value(value: mockUsersCubit),
          BlocProvider<SessionCubit>.value(value: mockSessionCubit),
        ],
        child: CreateUpdateChecklistTemplatePage(template: template),
      ),
    );
  }

  testWidgets('hides the items section while creating a new template', (
    tester,
  ) async {
    stubState();

    await tester.pumpWidget(buildWidget());

    expect(find.text('Criando checklist'), findsOneWidget);
    expect(find.text('Itens do checklist'), findsNothing);
  });

  testWidgets('shows the items section and its items when editing', (
    tester,
  ) async {
    final template = ChecklistFactory.makeChecklistTemplateEntity();
    final items = [
      ChecklistFactory.makeChecklistItemEntity().copyWith(
        templateId: template.id,
        sortOrder: 0,
      ),
      ChecklistFactory.makeChecklistItemEntity().copyWith(
        templateId: template.id,
        sortOrder: 1,
      ),
    ];
    stubState(selected: template, items: items);

    await tester.pumpWidget(buildWidget(template: template));

    expect(find.text('Editando checklist'), findsOneWidget);
    expect(find.text('Itens do checklist'), findsOneWidget);
    for (final item in items) {
      expect(find.text(item.label), findsOneWidget);
    }
  });

  testWidgets('shows the empty items message when the template has none', (
    tester,
  ) async {
    final template = ChecklistFactory.makeChecklistTemplateEntity();
    stubState(selected: template);

    await tester.pumpWidget(buildWidget(template: template));

    expect(find.text('Nenhum item cadastrado neste checklist'), findsOneWidget);
  });

  testWidgets('saves the template with its current field values', (
    tester,
  ) async {
    final template = ChecklistFactory.makeChecklistTemplateEntity();
    stubState(selected: template);

    await tester.pumpWidget(buildWidget(template: template));
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    verify(
      () => mockCubit.saveTemplate(
        id: template.id,
        name: template.name,
        description: template.description ?? '',
        categoryId: template.categoryId,
        createdAt: template.createdAt,
      ),
    ).called(1);
  });
}
