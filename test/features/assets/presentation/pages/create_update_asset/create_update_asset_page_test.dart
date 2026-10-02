import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_criticality.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/create_update_asset_page.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/keyboard_visibility/keyboard_visibility_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';

import '../../../../../../testing/mocks/factories/asset_factory.dart';
import '../../../../../../testing/mocks/factories/customer_factory.dart';
import '../../../../../../testing/mocks/factories/user_factory.dart';

class MockAssetsCubit extends MockCubit<AssetsState> implements AssetsCubit {}

class MockLocationsCubit extends MockCubit<LocationsState>
    implements LocationsCubit {}

class MockCategoriesCubit extends MockCubit<CategoriesState>
    implements CategoriesCubit {}

class MockCompanyCubit extends MockCubit<CompanyState>
    implements CompanyCubit {}

class MockCustomersCubit extends MockCubit<CustomersState>
    implements CustomersCubit {}

class MockKeyboardVisibilityCubit extends MockCubit<bool>
    implements KeyboardVisibilityCubit {}

void main() {
  late MockAssetsCubit mockAssetsCubit;
  late MockLocationsCubit mockLocationsCubit;
  late MockCategoriesCubit mockCategoriesCubit;
  late MockCompanyCubit mockCompanyCubit;
  late MockCustomersCubit mockCustomersCubit;
  late MockKeyboardVisibilityCubit mockKeyboardVisibilityCubit;

  final tLocation = AssetFactory.makeLocationEntity().copyWith(
    id: 'loc-1',
    name: 'Sede Principal',
  );
  final tCustomer = CustomerFactory.makeCustomerEntity().copyWith(
    id: 'cust-1',
    name: 'Cliente Alpha',
    isActive: true,
  );

  setUpAll(() {
    registerFallbackValue(WorkType.internalOnly);
    registerFallbackValue(AssetStatus.active);
    registerFallbackValue(AssetCriticality.medium);
  });

  setUp(() {
    mockAssetsCubit = MockAssetsCubit();
    mockLocationsCubit = MockLocationsCubit();
    mockCategoriesCubit = MockCategoriesCubit();
    mockCompanyCubit = MockCompanyCubit();
    mockCustomersCubit = MockCustomersCubit();
    mockKeyboardVisibilityCubit = MockKeyboardVisibilityCubit();

    when(() => mockAssetsCubit.state).thenReturn(
      const AssetsState(
        assets: [],
        sections: {
          BaseSections.load: SectionState.success(),
          AssetsSections.save: SectionState.idle(),
        },
      ),
    );

    when(() => mockLocationsCubit.state).thenReturn(
      LocationsState(
        locations: [tLocation],
        areasByLocation: const {'loc-1': []},
        allAreas: const [],
        sections: const {BaseSections.load: SectionState.success()},
      ),
    );

    when(() => mockCategoriesCubit.state).thenReturn(
      const CategoriesState(
        categories: [],
        sections: {BaseSections.load: SectionState.success()},
      ),
    );

    when(() => mockCustomersCubit.state).thenReturn(
      CustomersState(
        customers: [tCustomer],
        sections: const {BaseSections.load: SectionState.success()},
      ),
    );

    when(() => mockKeyboardVisibilityCubit.state).thenReturn(false);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Finder findDropdown(String key) => find.byWidgetPredicate(
    (w) => w is BaseDropDown<String> && w.key == ValueKey(key),
  );

  Widget createWidget({
    WorkType workType = WorkType.internalOnly,
    AssetEntity? asset,
  }) {
    final company = UserFactory.makeCompanyEntity().copyWith(
      workType: workType,
    );
    when(() => mockCompanyCubit.state).thenReturn(
      CompanyState(
        company: company,
        sections: const {BaseSections.load: SectionState.success()},
      ),
    );

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AssetsCubit>.value(value: mockAssetsCubit),
          BlocProvider<LocationsCubit>.value(value: mockLocationsCubit),
          BlocProvider<CategoriesCubit>.value(value: mockCategoriesCubit),
          BlocProvider<CompanyCubit>.value(value: mockCompanyCubit),
          BlocProvider<CustomersCubit>.value(value: mockCustomersCubit),
          BlocProvider<KeyboardVisibilityCubit>.value(
            value: mockKeyboardVisibilityCubit,
          ),
        ],
        child: CreateUpdateAssetPage(asset: asset),
      ),
    );
  }

  group('CreateUpdateAssetPage WorkType Adaptation', () {
    testWidgets('internalOnly renders Location/Area and hides Customer', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(findDropdown('Location'), findsOneWidget);
      expect(findDropdown('Area'), findsOneWidget);
      expect(findDropdown('AssetCustomer'), findsNothing);
    });

    testWidgets(
      'serviceProviderOnly hides Location/Area and renders Customer',
      (tester) async {
        await tester.pumpWidget(
          createWidget(workType: WorkType.serviceProviderOnly),
        );
        await tester.pumpAndSettle();

        expect(findDropdown('Location'), findsNothing);
        expect(findDropdown('Area'), findsNothing);
        expect(findDropdown('AssetCustomer'), findsOneWidget);
      },
    );

    testWidgets('hybrid renders Location, Area, and Customer', (tester) async {
      await tester.pumpWidget(createWidget(workType: WorkType.hybrid));
      await tester.pumpAndSettle();

      expect(findDropdown('Location'), findsOneWidget);
      expect(findDropdown('Area'), findsOneWidget);
      expect(findDropdown('AssetCustomer'), findsOneWidget);
    });

    testWidgets(
      'allows saving asset with location only and no area (Plan 02)',
      (tester) async {
        when(
          () => mockAssetsCubit.saveAsset(
            id: any(named: 'id'),
            locationId: any(named: 'locationId'),
            areaId: any(named: 'areaId'),
            customerId: any(named: 'customerId'),
            categoryId: any(named: 'categoryId'),
            parentAssetId: any(named: 'parentAssetId'),
            name: any(named: 'name'),
            code: any(named: 'code'),
            manufacturer: any(named: 'manufacturer'),
            model: any(named: 'model'),
            serialNumber: any(named: 'serialNumber'),
            status: any(named: 'status'),
            criticality: any(named: 'criticality'),
            notes: any(named: 'notes'),
            createdAt: any(named: 'createdAt'),
          ),
        ).thenAnswer((_) async => true);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        // Enter asset name
        await tester.enterText(
          find.byType(EditableText).first,
          'Gerador Diesel',
        );
        await tester.pumpAndSettle();

        // Select location
        await tester.tap(findDropdown('Location'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sede Principal').last);
        await tester.pumpAndSettle();

        // Drag to reveal submit button
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -600),
        );
        await tester.pumpAndSettle();

        final submitButton = find.widgetWithText(BaseButton, 'Salvar');
        expect(submitButton, findsOneWidget);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        verify(
          () => mockAssetsCubit.saveAsset(
            id: null,
            locationId: 'loc-1',
            name: 'Gerador Diesel',
            code: '',
            manufacturer: '',
            model: '',
            serialNumber: '',
            status: AssetStatus.active,
            criticality: AssetCriticality.medium,
            notes: '',
          ),
        ).called(1);
      },
    );

    testWidgets('allows saving asset with customer only (Plan 01 Phase 4)', (
      tester,
    ) async {
      when(
        () => mockAssetsCubit.saveAsset(
          id: any(named: 'id'),
          locationId: any(named: 'locationId'),
          areaId: any(named: 'areaId'),
          customerId: any(named: 'customerId'),
          categoryId: any(named: 'categoryId'),
          parentAssetId: any(named: 'parentAssetId'),
          name: any(named: 'name'),
          code: any(named: 'code'),
          manufacturer: any(named: 'manufacturer'),
          model: any(named: 'model'),
          serialNumber: any(named: 'serialNumber'),
          status: any(named: 'status'),
          criticality: any(named: 'criticality'),
          notes: any(named: 'notes'),
          createdAt: any(named: 'createdAt'),
        ),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(
        createWidget(workType: WorkType.serviceProviderOnly),
      );
      await tester.pumpAndSettle();

      // Enter asset name
      await tester.enterText(
        find.byType(EditableText).first,
        'Compressor do Cliente',
      );
      await tester.pumpAndSettle();

      // Select customer
      await tester.tap(findDropdown('AssetCustomer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cliente Alpha').last);
      await tester.pumpAndSettle();

      // Drag to reveal submit button
      await tester.drag(
        find.byType(SingleChildScrollView).last,
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      final submitButton = find.widgetWithText(BaseButton, 'Salvar');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      verify(
        () => mockAssetsCubit.saveAsset(
          id: null,
          customerId: 'cust-1',
          name: 'Compressor do Cliente',
          code: '',
          manufacturer: '',
          model: '',
          serialNumber: '',
          status: AssetStatus.active,
          criticality: AssetCriticality.medium,
          notes: '',
        ),
      ).called(1);
    });

    testWidgets(
      'serviceProviderOnly disables code and serial number for generic asset and saves nulls',
      (tester) async {
        when(
          () => mockAssetsCubit.saveAsset(
            id: any(named: 'id'),
            locationId: any(named: 'locationId'),
            areaId: any(named: 'areaId'),
            customerId: any(named: 'customerId'),
            categoryId: any(named: 'categoryId'),
            parentAssetId: any(named: 'parentAssetId'),
            name: any(named: 'name'),
            code: any(named: 'code'),
            manufacturer: any(named: 'manufacturer'),
            model: any(named: 'model'),
            serialNumber: any(named: 'serialNumber'),
            status: any(named: 'status'),
            criticality: any(named: 'criticality'),
            notes: any(named: 'notes'),
            createdAt: any(named: 'createdAt'),
          ),
        ).thenAnswer((_) async => true);

        await tester.pumpWidget(
          createWidget(workType: WorkType.serviceProviderOnly),
        );
        await tester.pumpAndSettle();

        final codeField = tester.widget<BaseTextFormField>(
          find.widgetWithText(BaseTextFormField, 'Código (opcional)'),
        );
        final serialField = tester.widget<BaseTextFormField>(
          find.widgetWithText(BaseTextFormField, 'Nº série (opcional)'),
        );
        expect(codeField.enabled, isFalse);
        expect(serialField.enabled, isFalse);
        expect(
          find.text('Código e número de série requerem um cliente vinculado'),
          findsOneWidget,
        );

        await tester.enterText(
          find.byType(EditableText).first,
          'Bomba Genérica',
        );
        await tester.pumpAndSettle();

        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -600),
        );
        await tester.pumpAndSettle();

        final submitButton = find.widgetWithText(BaseButton, 'Salvar');
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        verify(
          () => mockAssetsCubit.saveAsset(
            id: null,
            name: 'Bomba Genérica',
            manufacturer: '',
            model: '',
            status: AssetStatus.active,
            criticality: AssetCriticality.medium,
            notes: '',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'asset.customerId pre-populates customer field and enables unit fields without locking',
      (tester) async {
        final tAssetWithCustomer = AssetFactory.makeAssetEntity().copyWith(
          id: '',
          customerId: 'cust-1',
        );

        await tester.pumpWidget(
          createWidget(
            workType: WorkType.serviceProviderOnly,
            asset: tAssetWithCustomer,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Cliente Alpha'), findsOneWidget);

        final codeField = tester.widget<BaseTextFormField>(
          find.widgetWithText(BaseTextFormField, 'Código (opcional)'),
        );
        final serialField = tester.widget<BaseTextFormField>(
          find.widgetWithText(BaseTextFormField, 'Nº série (opcional)'),
        );
        expect(codeField.enabled, isTrue);
        expect(serialField.enabled, isTrue);
        expect(
          find.text('Código e número de série requerem um cliente vinculado'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'hybrid allows saving customer asset without requiring location',
      (tester) async {
        when(
          () => mockAssetsCubit.saveAsset(
            id: any(named: 'id'),
            locationId: any(named: 'locationId'),
            areaId: any(named: 'areaId'),
            customerId: any(named: 'customerId'),
            categoryId: any(named: 'categoryId'),
            parentAssetId: any(named: 'parentAssetId'),
            name: any(named: 'name'),
            code: any(named: 'code'),
            manufacturer: any(named: 'manufacturer'),
            model: any(named: 'model'),
            serialNumber: any(named: 'serialNumber'),
            status: any(named: 'status'),
            criticality: any(named: 'criticality'),
            notes: any(named: 'notes'),
            createdAt: any(named: 'createdAt'),
          ),
        ).thenAnswer((_) async => true);

        await tester.pumpWidget(createWidget(workType: WorkType.hybrid));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(EditableText).first,
          'Equipamento Híbrido Cliente',
        );
        await tester.pumpAndSettle();

        // Select customer without selecting location
        await tester.tap(findDropdown('AssetCustomer'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cliente Alpha').last);
        await tester.pumpAndSettle();

        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -600),
        );
        await tester.pumpAndSettle();

        final submitButton = find.widgetWithText(BaseButton, 'Salvar');
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        verify(
          () => mockAssetsCubit.saveAsset(
            id: null,
            customerId: 'cust-1',
            name: 'Equipamento Híbrido Cliente',
            code: '',
            manufacturer: '',
            model: '',
            serialNumber: '',
            status: AssetStatus.active,
            criticality: AssetCriticality.medium,
            notes: '',
          ),
        ).called(1);
      },
    );
  });
}
