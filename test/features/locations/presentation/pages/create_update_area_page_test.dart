import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/create_update_area/create_update_area_page.dart';

import '../../../../../testing/mocks/cubits/locations_mocks.dart';
import '../../../../../testing/mocks/factories/asset_factory.dart';

void main() {
  late MockLocationsCubit cubit;
  final location = AssetFactory.makeLocationEntity();
  final submissions = <Map<Symbol, dynamic>>[];
  var saveSucceeds = false;

  void formTest(String description, WidgetTesterCallback callback) {
    testWidgets(
      description,
      callback,
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  }

  setUp(() {
    submissions.clear();
    saveSucceeds = false;
    cubit = MockLocationsCubit();
    when(() => cubit.state).thenReturn(const LocationsState.initial());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => cubit.saveArea(
        id: any(named: 'id'),
        locationId: any(named: 'locationId'),
        name: any(named: 'name'),
        floor: any(named: 'floor'),
        description: any(named: 'description'),
        createdAt: any(named: 'createdAt'),
      ),
    ).thenAnswer((invocation) async {
      submissions.add(invocation.namedArguments);
      return saveSucceeds;
    });
  });
  tearDown(() => cubit.close());

  Future<void> openForm(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<LocationsCubit>.value(
        value: cubit,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CreateUpdateAreaPage(
                      locationId: location.id,
                      companyId: location.companyId,
                    ),
                  ),
                ),
                child: const Text('Open area'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open area'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Criar'));
    await tester.tap(find.text('Criar'));
    await tester.pumpAndSettle();
  }

  for (final name in ['', '   ']) {
    formTest('rejects ${name.isEmpty ? 'empty' : 'whitespace'} area name', (
      tester,
    ) async {
      await openForm(tester);
      await tester.enterText(find.byType(TextFormField).first, name);
      await save(tester);
      expect(submissions, isEmpty);
      expect(find.text('Campo obrigatório'), findsOneWidget);
      expect(find.byType(CreateUpdateAreaPage), findsOneWidget);
    });
  }

  formTest(
    'failed create retains all fields and retry preserves the selected location',
    (tester) async {
      await openForm(tester);
      await tester.enterText(find.byType(TextFormField).at(0), 'Workshop');
      await tester.enterText(find.byType(TextFormField).at(1), 'Ground floor');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Near loading bay',
      );
      await save(tester);
      expect(find.byType(CreateUpdateAreaPage), findsOneWidget);
      expect(find.text('Workshop'), findsOneWidget);
      expect(find.text('Ground floor'), findsOneWidget);
      expect(find.text('Near loading bay'), findsOneWidget);
      expect(submissions.single, {
        #id: null,
        #locationId: location.id,
        #name: 'Workshop',
        #floor: 'Ground floor',
        #description: 'Near loading bay',
        #createdAt: null,
      });
      saveSucceeds = true;
      await save(tester);
      expect(submissions, hasLength(2));
      expect(submissions.last, submissions.first);
      expect(find.byType(CreateUpdateAreaPage), findsNothing);
      expect(find.text('Open area'), findsOneWidget);
    },
  );

  formTest('back abandons an unsaved area without submitting', (tester) async {
    await openForm(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Unsaved area');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(submissions, isEmpty);
    expect(find.byType(CreateUpdateAreaPage), findsNothing);
    expect(find.text('Open area'), findsOneWidget);
  });
}
