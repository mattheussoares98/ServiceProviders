import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/address_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/create_update_location/create_update_location_page.dart';

import '../../../../../testing/mocks/cubits/locations_mocks.dart';
import '../../../../../testing/mocks/factories/asset_factory.dart';

void main() {
  late MockLocationsCubit cubit;

  void formTest(String description, WidgetTesterCallback callback) {
    testWidgets(
      description,
      callback,
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  }

  setUp(() {
    cubit = MockLocationsCubit();
    when(
      () => cubit.saveLocation(
        id: any(named: 'id'),
        name: any(named: 'name'),
        postalCode: any(named: 'postalCode'),
        address: any(named: 'address'),
        number: any(named: 'number'),
        complement: any(named: 'complement'),
        neighborhood: any(named: 'neighborhood'),
        city: any(named: 'city'),
        addressState: any(named: 'addressState'),
        createdAt: any(named: 'createdAt'),
      ),
    ).thenAnswer((_) async => false);

    when(() => cubit.state).thenReturn(const LocationsState.initial());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() async {
    await cubit.close();
  });

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
                    builder: (_) => const CreateUpdateLocationPage(),
                  ),
                ),
                child: const Text('Open form'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
  }

  for (final name in ['', '   ']) {
    formTest(
      'rejects ${name.isEmpty ? 'empty' : 'whitespace'} name before saving',
      (tester) async {
        await openForm(tester);
        await tester.enterText(find.byType(TextFormField).first, name);
        clearInteractions(cubit);
        await save(tester);
        expect(find.text('Campo obrigatório'), findsOneWidget);
        expect(find.byType(CreateUpdateLocationPage), findsOneWidget);
        verifyNever(
          () => cubit.saveLocation(
            id: any(named: 'id'),
            name: any(named: 'name'),
            postalCode: any(named: 'postalCode'),
            address: any(named: 'address'),
            number: any(named: 'number'),
            complement: any(named: 'complement'),
            neighborhood: any(named: 'neighborhood'),
            city: any(named: 'city'),
            addressState: any(named: 'addressState'),
            createdAt: any(named: 'createdAt'),
          ),
        );
      },
    );
  }

  formTest(
    'keeps entered values after failed save and closes after successful retry',
    (tester) async {
      var attempts = 0;
      when(
        () => cubit.saveLocation(
          id: any(named: 'id'),
          name: any(named: 'name'),
          postalCode: any(named: 'postalCode'),
          address: any(named: 'address'),
          number: any(named: 'number'),
          complement: any(named: 'complement'),
          neighborhood: any(named: 'neighborhood'),
          city: any(named: 'city'),
          addressState: any(named: 'addressState'),
          createdAt: any(named: 'createdAt'),
        ),
      ).thenAnswer((_) async => ++attempts == 2);
      await openForm(tester);
      await tester.enterText(
        find.byType(TextFormField).first,
        'North workshop',
      );
      await save(tester);
      expect(find.byType(CreateUpdateLocationPage), findsOneWidget);
      expect(find.text('North workshop'), findsOneWidget);
      await save(tester);
      expect(attempts, 2);
      expect(find.byType(CreateUpdateLocationPage), findsNothing);
      expect(find.text('Open form'), findsOneWidget);
    },
  );

  formTest('cancel returns to the previous page', (tester) async {
    await openForm(tester);
    await tester.enterText(
      find.byType(TextFormField).first,
      'Unsaved location',
    );
    await tester.ensureVisible(find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateUpdateLocationPage), findsNothing);
    expect(find.text('Open form'), findsOneWidget);
  });

  formTest('manual address edit survives a pending postal code lookup', (
    tester,
  ) async {
    final lookup = Completer<AddressEntity?>();
    when(
      () => cubit.getAddressByCep('01001000'),
    ).thenAnswer((_) => lookup.future);
    await openForm(tester);
    await tester.enterText(find.byType(TextFormField).at(1), '01001000');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Manually corrected street',
    );
    lookup.complete(
      AssetFactory.makeAddressEntity().copyWith(
        street: 'Postal service street',
      ),
    );
    await tester.pumpAndSettle();
    final field = tester.widget<TextFormField>(
      find.byType(TextFormField).at(2),
    );
    expect(field.controller!.text, 'Manually corrected street');
  });
}
