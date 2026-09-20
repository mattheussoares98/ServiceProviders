import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/create_update_area/create_update_area_page.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/create_update_location/create_update_location_page.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';

import '../../../../../testing/mocks/cubits/locations_mocks.dart';
import '../../../../../testing/mocks/cubits/registry_context_mocks.dart';
import '../../../../../testing/mocks/factories/asset_factory.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';

void main() {
  late MockLocationsCubit cubit;
  late MockRegistryUsersCubit users;
  late MockRegistrySessionCubit session;
  final location = AssetFactory.makeLocationEntity().copyWith(
    name: 'Original location',
  );
  final area = AssetFactory.makeAreaEntity().copyWith(
    locationId: location.id,
    companyId: location.companyId,
    name: 'Original area',
    floor: 'Level 2',
    description: 'Original description',
  );
  final submissions = <Map<Symbol, dynamic>>[];

  setUpAll(
    () => registerFallbackValue(
      const ActionPermission.resource(
        resourceType: ResourceType.locations,
        permissionAction: PermissionAction.delete,
      ),
    ),
  );

  setUp(() {
    submissions.clear();
    cubit = MockLocationsCubit();
    users = MockRegistryUsersCubit();
    session = MockRegistrySessionCubit();
    when(() => cubit.state).thenReturn(const LocationsState.initial());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => users.state).thenReturn(const UsersState.initial());
    when(() => users.stream).thenAnswer((_) => const Stream.empty());
    when(() => users.hasPermission(any())).thenReturn(true);
    when(() => session.state).thenReturn(
      SessionState(user: UserFactory.makeUserProfileEntity(), isLoggedIn: true),
    );
    when(() => session.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => cubit.saveArea(
        id: any(named: 'id'),
        locationId: any(named: 'locationId'),
        name: any(named: 'name'),
        floor: any(named: 'floor'),
        description: any(named: 'description'),
        createdAt: any(named: 'createdAt'),
      ),
    ).thenAnswer((i) async {
      submissions.add(i.namedArguments);
      return true;
    });
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
    ).thenAnswer((i) async {
      submissions.add(i.namedArguments);
      return true;
    });
    when(() => cubit.deleteLocation(any())).thenAnswer((_) async {});
    when(() => cubit.deleteArea(any(), any())).thenAnswer((_) async => false);
  });

  tearDown(() async {
    await cubit.close();
    await users.close();
    await session.close();
  });

  Future<void> open(WidgetTester tester, {required bool isArea}) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocationsCubit>.value(value: cubit),
          BlocProvider<UsersCubit>.value(value: users),
          BlocProvider<SessionCubit>.value(value: session),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => isArea
                        ? CreateUpdateAreaPage(
                            locationId: location.id,
                            companyId: location.companyId,
                            area: area,
                          )
                        : CreateUpdateLocationPage(existingLocation: location),
                  ),
                ),
                child: const Text('Registry'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Registry'));
    await tester.pumpAndSettle();
  }

  for (final isArea in [false, true]) {
    final kind = isArea ? 'area' : 'location';
    testWidgets(
      '$kind edit preserves identity and sends cleared optional values',
      (tester) async {
        await open(tester, isArea: isArea);
        expect(find.text(isArea ? area.name : location.name), findsOneWidget);
        await tester.enterText(
          find.byType(TextFormField).first,
          'Renamed registry',
        );
        for (var i = 1; i < find.byType(TextFormField).evaluate().length; i++) {
          await tester.enterText(find.byType(TextFormField).at(i), '');
        }
        await tester.ensureVisible(find.text('Salvar'));
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();
        final sent = submissions.single;
        expect(sent[#id], isArea ? area.id : location.id);
        expect(sent[#createdAt], isArea ? area.createdAt : location.createdAt);
        expect(sent[#name], 'Renamed registry');
        for (final key
            in isArea
                ? [#floor, #description]
                : [
                    #postalCode,
                    #address,
                    #number,
                    #complement,
                    #neighborhood,
                    #city,
                    #addressState,
                  ]) {
          expect(sent[key], '', reason: '$key must clear the old value');
        }
        if (isArea) expect(sent[#locationId], location.id);
        expect(find.text('Registry'), findsOneWidget);
        expect(find.text('Salvar'), findsNothing);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );

    testWidgets('$kind cancelled deletion never calls the mutation', (
      tester,
    ) async {
      await open(tester, isArea: isArea);
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(kDialogDefaultKey),
          matching: find.text('Cancelar'),
        ),
      );
      await tester.pumpAndSettle();
      verifyNever(() => cubit.deleteArea(any(), any()));
      verifyNever(() => cubit.deleteLocation(any()));
      expect(find.text(isArea ? area.name : location.name), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets(
      '$kind confirmed deletion sends the displayed record identity once',
      (tester) async {
        await open(tester, isArea: isArea);
        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sim'));
        await tester.pumpAndSettle();
        if (isArea) {
          verify(() => cubit.deleteArea(area.id, location.id)).called(1);
          verifyNever(() => cubit.popRoute());
          expect(find.text(area.name), findsOneWidget);
        } else {
          verify(() => cubit.deleteLocation(location.id)).called(1);
        }
        expect(find.byKey(kDialogDefaultKey), findsNothing);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  }

  testWidgets('successful area deletion requests leaving the editor', (
    tester,
  ) async {
    when(
      () => cubit.deleteArea(area.id, location.id),
    ).thenAnswer((_) async => true);
    await open(tester, isArea: true);
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sim'));
    await tester.pumpAndSettle();
    verify(() => cubit.popRoute()).called(1);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
