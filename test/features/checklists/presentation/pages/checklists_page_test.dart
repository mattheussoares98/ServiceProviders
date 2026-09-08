import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/pages/checklists/checklists_page.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
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
  });

  setUp(() {
    mockCubit = MockChecklistTemplatesCubit();
    mockUsersCubit = MockUsersCubit();
    mockSessionCubit = MockSessionCubit();

    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
    when(() => mockSessionCubit.state).thenReturn(
      SessionState(user: UserFactory.makeUserProfileEntity(), isLoggedIn: true),
    );
  });

  Widget buildWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ChecklistTemplatesCubit>.value(value: mockCubit),
          BlocProvider<UsersCubit>.value(value: mockUsersCubit),
          BlocProvider<SessionCubit>.value(value: mockSessionCubit),
        ],
        child: const ChecklistsPage(),
      ),
    );
  }

  void stubState(List<ChecklistTemplateEntity> templates) {
    when(() => mockCubit.state).thenReturn(
      ChecklistTemplatesState(
        templates: templates,
        templateItems: const [],
        sections: const {BaseSections.load: SectionState.success()},
      ),
    );
  }

  testWidgets('renders the empty message when no template exists', (
    tester,
  ) async {
    stubState(const []);

    await tester.pumpWidget(buildWidget());

    expect(find.text('Checklists'), findsOneWidget);
    expect(find.text('Nenhum checklist cadastrado'), findsOneWidget);
  });

  testWidgets('renders one card per template', (tester) async {
    final templates = [
      ChecklistFactory.makeChecklistTemplateEntity(),
      ChecklistFactory.makeChecklistTemplateEntity(),
    ];
    stubState(templates);

    await tester.pumpWidget(buildWidget());

    for (final template in templates) {
      expect(find.text(template.name), findsOneWidget);
    }
  });

  testWidgets('tapping a template navigates to its editor', (tester) async {
    final template = ChecklistFactory.makeChecklistTemplateEntity();
    stubState([template]);
    when(
      () => mockCubit.navigateToCreateUpdateTemplate(
        template: any(named: 'template'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(buildWidget());
    await tester.tap(find.text(template.name));
    await tester.pump();

    verify(
      () => mockCubit.navigateToCreateUpdateTemplate(template: template),
    ).called(1);
  });

  testWidgets('shows the loading indicator while templates load', (
    tester,
  ) async {
    when(() => mockCubit.state).thenReturn(
      const ChecklistTemplatesState(
        templates: [],
        templateItems: [],
        sections: {BaseSections.load: SectionState.running()},
      ),
    );

    await tester.pumpWidget(buildWidget());

    expect(find.text('Nenhum checklist cadastrado'), findsNothing);
  });
}
