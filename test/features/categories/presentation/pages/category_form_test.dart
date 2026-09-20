import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/pages/create_update_category/create_update_category_page.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';

import '../../../../../testing/mocks/cubits/categories_mocks.dart';
import '../../../../../testing/mocks/cubits/registry_context_mocks.dart';
import '../../../../../testing/mocks/factories/asset_factory.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';

void main() {
  late MockCategoriesCubit cubit;
  late MockRegistryUsersCubit users;
  late MockRegistrySessionCubit session;
  final category = AssetFactory.makeCategoryEntity().copyWith(
    name: 'Electrical',
    description: 'Original description',
  );
  final submissions = <Map<Symbol, dynamic>>[];
  var succeeds = false;

  void formTest(String name, WidgetTesterCallback callback) => testWidgets(
    name,
    callback,
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  setUpAll(
    () => registerFallbackValue(
      const ActionPermission.resource(
        resourceType: ResourceType.categories,
        permissionAction: PermissionAction.delete,
      ),
    ),
  );
  setUp(() {
    submissions.clear();
    succeeds = false;
    cubit = MockCategoriesCubit();
    users = MockRegistryUsersCubit();
    session = MockRegistrySessionCubit();
    when(() => cubit.state).thenReturn(const CategoriesState.initial());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => users.state).thenReturn(const UsersState.initial());
    when(() => users.stream).thenAnswer((_) => const Stream.empty());
    when(() => users.hasPermission(any())).thenReturn(true);
    when(() => session.state).thenReturn(
      SessionState(user: UserFactory.makeUserProfileEntity(), isLoggedIn: true),
    );
    when(() => session.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => cubit.saveCategory(
        id: any(named: 'id'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        color: any(named: 'color'),
        createdAt: any(named: 'createdAt'),
      ),
    ).thenAnswer((i) async {
      submissions.add(i.namedArguments);
      return succeeds;
    });
    when(() => cubit.deleteCategory(any())).thenAnswer((_) async => succeeds);
  });
  tearDown(() async {
    await cubit.close();
    await users.close();
    await session.close();
  });

  Future<void> open(WidgetTester tester, {bool editing = false}) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<CategoriesCubit>.value(value: cubit),
          BlocProvider<UsersCubit>.value(value: users),
          BlocProvider<SessionCubit>.value(value: session),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CreateUpdateCategoryPage(
                      category: editing ? category : null,
                    ),
                  ),
                ),
                child: const Text('Category list'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Category list'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
  }

  formTest(
    'unchanged edit is disabled and reverting edits disables save again',
    (tester) async {
      await open(tester, editing: true);
      expect(tester.widget<BaseButton>(find.byType(BaseButton)).onTap, isNull);
      await tester.enterText(find.byType(TextFormField).first, 'Changed');
      await tester.pump();
      expect(
        tester.widget<BaseButton>(find.byType(BaseButton)).onTap,
        isNotNull,
      );
      await tester.enterText(find.byType(TextFormField).first, category.name);
      await tester.pump();
      expect(tester.widget<BaseButton>(find.byType(BaseButton)).onTap, isNull);
      expect(submissions, isEmpty);
    },
  );

  for (final name in ['ab', '   ', ' a ']) {
    formTest('rejects invalid trimmed category name "$name"', (tester) async {
      await open(tester);
      await tester.enterText(find.byType(TextFormField).first, name);
      await tester.enterText(
        find.byType(TextFormField).last,
        'Enable changed form',
      );
      await save(tester);
      expect(submissions, isEmpty);
      expect(find.byType(CreateUpdateCategoryPage), findsOneWidget);
    });
  }

  formTest(
    'failed edit retains input and retry clears description without losing identity or color',
    (tester) async {
      await open(tester, editing: true);
      await tester.enterText(
        find.byType(TextFormField).first,
        'Renamed category',
      );
      await tester.enterText(find.byType(TextFormField).last, '');
      await save(tester);
      expect(find.text('Renamed category'), findsOneWidget);
      expect(submissions.single, {
        #id: category.id,
        #name: 'Renamed category',
        #description: '',
        #color: category.color,
        #createdAt: category.createdAt,
      });
      succeeds = true;
      await save(tester);
      expect(submissions, hasLength(2));
      expect(submissions.last, submissions.first);
      expect(find.text('Category list'), findsOneWidget);
    },
  );

  formTest('cancel deletion keeps record and confirmed failure permits retry', (
    tester,
  ) async {
    await open(tester, editing: true);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Não'));
    await tester.pumpAndSettle();
    verifyNever(() => cubit.deleteCategory(any()));
    for (final success in [false, true]) {
      succeeds = success;
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sim'));
      await tester.pumpAndSettle();
      verify(() => cubit.deleteCategory(category.id)).called(1);
      expect(
        find.byType(CreateUpdateCategoryPage),
        success ? findsNothing : findsOneWidget,
      );
    }
    expect(find.text('Category list'), findsOneWidget);
  });
}
