import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/widgets/searchable_asset/searchable_asset_picker_modal.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/sla_policies/presentation/cubits/sla_policies/sla_policies_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/create_update_work_order_page.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

import '../../../../../../testing/mocks/factories/asset_factory.dart';
import '../../../../../../testing/mocks/factories/customer_factory.dart';
import '../../../../../../testing/mocks/factories/user_factory.dart';

class MockWorkOrdersCubit extends MockCubit<WorkOrdersState>
    implements WorkOrdersCubit {}

class MockCompanyCubit extends MockCubit<CompanyState>
    implements CompanyCubit {}

class MockCustomersCubit extends MockCubit<CustomersState>
    implements CustomersCubit {}

class MockLocationsCubit extends MockCubit<LocationsState>
    implements LocationsCubit {}

class MockAssetsCubit extends MockCubit<AssetsState> implements AssetsCubit {}

class MockUsersCubit extends MockCubit<UsersState> implements UsersCubit {}

class MockServiceProvidersCubit extends MockCubit<ServiceProvidersState>
    implements ServiceProvidersCubit {}

class MockChecklistTemplatesCubit extends MockCubit<ChecklistTemplatesState>
    implements ChecklistTemplatesCubit {}

class MockSlaPoliciesCubit extends MockCubit<SlaPoliciesState>
    implements SlaPoliciesCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockAttachmentsCubit extends MockCubit<AttachmentsState>
    implements AttachmentsCubit {}

class MockGetSelectedModeUseCase extends Mock
    implements GetSelectedModeUseCase {}

void main() {
  late MockWorkOrdersCubit mockWorkOrdersCubit;
  late MockCompanyCubit mockCompanyCubit;
  late MockCustomersCubit mockCustomersCubit;
  late MockLocationsCubit mockLocationsCubit;
  late MockAssetsCubit mockAssetsCubit;
  late MockUsersCubit mockUsersCubit;
  late MockServiceProvidersCubit mockServiceProvidersCubit;
  late MockChecklistTemplatesCubit mockChecklistCubit;
  late MockSlaPoliciesCubit mockSlaPoliciesCubit;
  late MockSessionCubit mockSessionCubit;
  late MockAttachmentsCubit mockAttachmentsCubit;
  late MockGetSelectedModeUseCase mockGetSelectedMode;

  final tCustomer = CustomerFactory.makeCustomerEntity().copyWith(
    id: 'customer-1',
    name: 'Cliente Teste',
    isActive: true,
  );
  final tLocation = AssetFactory.makeLocationEntity().copyWith(
    id: 'location-1',
    name: 'Sede Principal',
  );

  setUpAll(() {
    registerFallbackValue(WorkType.internalOnly);
    registerFallbackValue(Priority.medium);
    registerFallbackValue(WorkOrderStatus.open);
    registerFallbackValue(WorkOrderType.corrective);
    registerFallbackValue(AppMode.internal);
    registerFallbackValue(
      const ActionPermission.workOrderSubAction(
        WorkOrderSubAction.manageFinancials,
      ),
    );
  });

  setUp(() async {
    await GetIt.I.reset();

    mockWorkOrdersCubit = MockWorkOrdersCubit();
    mockCompanyCubit = MockCompanyCubit();
    mockCustomersCubit = MockCustomersCubit();
    mockLocationsCubit = MockLocationsCubit();
    mockAssetsCubit = MockAssetsCubit();
    mockUsersCubit = MockUsersCubit();
    mockServiceProvidersCubit = MockServiceProvidersCubit();
    mockChecklistCubit = MockChecklistTemplatesCubit();
    mockSlaPoliciesCubit = MockSlaPoliciesCubit();
    mockSessionCubit = MockSessionCubit();
    mockAttachmentsCubit = MockAttachmentsCubit();
    mockGetSelectedMode = MockGetSelectedModeUseCase();

    GetIt.I.registerSingleton<GetSelectedModeUseCase>(mockGetSelectedMode);
    when(() => mockGetSelectedMode.call()).thenReturn(AppMode.internal.name);

    const screenDetails = ScreenDetails(
      logicalSize: Size(1920, 1280),
      physicalSize: Size(1920, 1280),
      devicePixelRatio: 1,
    );
    ScreenUtil.I.configureScreen(screenDetails);

    when(
      () => mockWorkOrdersCubit.state,
    ).thenReturn(const WorkOrdersState.initial());
    when(
      () => mockWorkOrdersCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockWorkOrdersCubit.realtimeEvents,
    ).thenAnswer((_) => const Stream<RealtimeEvent<WorkOrderEntity>>.empty());

    when(() => mockCompanyCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockCustomersCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockLocationsCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockAssetsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockServiceProvidersCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockChecklistCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockSlaPoliciesCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockAttachmentsCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      () => mockCustomersCubit.state,
    ).thenReturn(CustomersState(customers: [tCustomer]));
    when(() => mockLocationsCubit.state).thenReturn(
      LocationsState(
        locations: [tLocation],
        areasByLocation: const {},
        allAreas: const [],
      ),
    );
    when(() => mockAssetsCubit.state).thenReturn(const AssetsState.initial());
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
    when(
      () => mockServiceProvidersCubit.state,
    ).thenReturn(const ServiceProvidersState.initial());
    when(
      () => mockChecklistCubit.state,
    ).thenReturn(const ChecklistTemplatesState.initial());
    when(
      () => mockSlaPoliciesCubit.state,
    ).thenReturn(const SlaPoliciesState.initial());
    when(() => mockSessionCubit.state).thenReturn(
      SessionState(user: UserFactory.makeUserProfileEntity(), isLoggedIn: true),
    );
    when(() => mockAttachmentsCubit.state).thenReturn(
      const AttachmentsState(
        sections: {BaseSections.load: SectionState.success()},
      ),
    );
    when(
      () => mockWorkOrdersCubit.saveWorkOrder(
        id: any(named: 'id'),
        isEditing: any(named: 'isEditing'),
        locationId: any(named: 'locationId'),
        customerId: any(named: 'customerId'),
        workType: any(named: 'workType'),
        areaId: any(named: 'areaId'),
        assetId: any(named: 'assetId'),
        assignedToId: any(named: 'assignedToId'),
        createdById: any(named: 'createdById'),
        createdByProviderProfileId: any(named: 'createdByProviderProfileId'),
        openedBy: any(named: 'openedBy'),
        title: any(named: 'title'),
        description: any(named: 'description'),
        priority: any(named: 'priority'),
        status: any(named: 'status'),
        type: any(named: 'type'),
        scheduledDate: any(named: 'scheduledDate'),
        estimatedDuration: any(named: 'estimatedDuration'),
        createdAt: any(named: 'createdAt'),
        actualDuration: any(named: 'actualDuration'),
        completedAt: any(named: 'completedAt'),
        laborCost: any(named: 'laborCost'),
        maintenancePlanId: any(named: 'maintenancePlanId'),
        notes: any(named: 'notes'),
        partsCost: any(named: 'partsCost'),
        startedAt: any(named: 'startedAt'),
        totalCost: any(named: 'totalCost'),
        price: any(named: 'price'),
        currency: any(named: 'currency'),
        attachmentsCubit: any(named: 'attachmentsCubit'),
        serviceProviderCompanyId: any(named: 'serviceProviderCompanyId'),
        providerProfileId: any(named: 'providerProfileId'),
        slaPolicyId: any(named: 'slaPolicyId'),
        checklistTemplateId: any(named: 'checklistTemplateId'),
      ),
    ).thenAnswer((_) async => true);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Widget buildWidget({WorkType workType = WorkType.internalOnly}) {
    when(() => mockCompanyCubit.state).thenReturn(
      CompanyState(
        company: UserFactory.makeCompanyEntity().copyWith(workType: workType),
      ),
    );

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<WorkOrdersCubit>.value(value: mockWorkOrdersCubit),
          BlocProvider<CompanyCubit>.value(value: mockCompanyCubit),
          BlocProvider<CustomersCubit>.value(value: mockCustomersCubit),
          BlocProvider<LocationsCubit>.value(value: mockLocationsCubit),
          BlocProvider<AssetsCubit>.value(value: mockAssetsCubit),
          BlocProvider<UsersCubit>.value(value: mockUsersCubit),
          BlocProvider<ServiceProvidersCubit>.value(
            value: mockServiceProvidersCubit,
          ),
          BlocProvider<ChecklistTemplatesCubit>.value(
            value: mockChecklistCubit,
          ),
          BlocProvider<SlaPoliciesCubit>.value(value: mockSlaPoliciesCubit),
          BlocProvider<SessionCubit>.value(value: mockSessionCubit),
        ],
        child: CreateUpdateWorkOrderPage(
          attachmentsCubit: mockAttachmentsCubit,
        ),
      ),
    );
  }

  Finder findDropdown(String key) => find.byWidgetPredicate(
    (w) => w is BaseDropDown<String> && w.key == ValueKey(key),
  );

  Finder findSaveButton() => find.byType(BaseIconButton).last;

  group('CreateUpdateWorkOrderPage WorkType behavior', () {
    testWidgets(
      'when workType is internalOnly: displays Location and Area dropdowns, hides Customer dropdown',
      (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(findDropdown('Location'), findsOneWidget);
        expect(findDropdown('Area'), findsOneWidget);
        expect(findDropdown('Customer'), findsNothing);
      },
    );

    testWidgets(
      'when workType is serviceProviderOnly: displays Customer dropdown, hides Location and Area dropdowns',
      (tester) async {
        await tester.pumpWidget(
          buildWidget(workType: WorkType.serviceProviderOnly),
        );
        await tester.pumpAndSettle();

        expect(findDropdown('Customer'), findsOneWidget);
        expect(findDropdown('Location'), findsNothing);
        expect(findDropdown('Area'), findsNothing);
      },
    );

    testWidgets(
      'when workType is hybrid: displays Customer, Location, and Area dropdowns',
      (tester) async {
        await tester.pumpWidget(buildWidget(workType: WorkType.hybrid));
        await tester.pumpAndSettle();

        expect(findDropdown('Customer'), findsOneWidget);
        expect(findDropdown('Location'), findsOneWidget);
        expect(findDropdown('Area'), findsOneWidget);
      },
    );

    testWidgets(
      'when in providerMode: always behaves as internal facility mode regardless of company workType',
      (tester) async {
        when(
          () => mockGetSelectedMode.call(),
        ).thenReturn(AppMode.provider.name);

        await tester.pumpWidget(
          buildWidget(workType: WorkType.serviceProviderOnly),
        );
        await tester.pumpAndSettle();

        expect(findDropdown('Location'), findsOneWidget);
        expect(findDropdown('Area'), findsOneWidget);
        expect(findDropdown('Customer'), findsNothing);
      },
    );

    testWidgets(
      'when serviceProviderOnly: validates customer requirement and submits with customerId',
      (tester) async {
        await tester.pumpWidget(
          buildWidget(workType: WorkType.serviceProviderOnly),
        );
        await tester.pumpAndSettle();

        // Fill title
        await tester.enterText(
          find.byType(EditableText).first,
          'Ordem Prestador',
        );
        await tester.pumpAndSettle();

        // Tap save without selecting customer
        await tester.tap(findSaveButton());
        await tester.pumpAndSettle();

        // Validation error appears
        expect(find.text('Selecione um cliente'), findsOneWidget);
        verifyNever(
          () => mockWorkOrdersCubit.saveWorkOrder(
            id: any(named: 'id'),
            isEditing: any(named: 'isEditing'),
            title: any(named: 'title'),
            priority: any(named: 'priority'),
            status: any(named: 'status'),
            type: any(named: 'type'),
          ),
        );

        // Select customer
        await tester.tap(findDropdown('Customer'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cliente Teste').last);
        await tester.pumpAndSettle();

        // Tap save again
        await tester.tap(findSaveButton());
        await tester.pumpAndSettle();

        expect(find.text('Salvar alterações?'), findsOneWidget);
        final actionCustomer = tester.widget<CupertinoDialogAction>(
          find.byType(CupertinoDialogAction).last,
        );
        actionCustomer.onPressed!();
        await tester.pumpAndSettle();

        verify(
          () => mockWorkOrdersCubit.saveWorkOrder(
            id: any(named: 'id'),
            isEditing: false,
            customerId: 'customer-1',
            workType: WorkType.serviceProviderOnly,
            areaId: any(named: 'areaId'),
            assetId: any(named: 'assetId'),
            assignedToId: any(named: 'assignedToId'),
            createdById: any(named: 'createdById'),
            createdByProviderProfileId: any(
              named: 'createdByProviderProfileId',
            ),
            openedBy: any(named: 'openedBy'),
            title: 'Ordem Prestador',
            description: any(named: 'description'),
            priority: any(named: 'priority'),
            status: any(named: 'status'),
            type: any(named: 'type'),
            scheduledDate: any(named: 'scheduledDate'),
            estimatedDuration: any(named: 'estimatedDuration'),
            createdAt: any(named: 'createdAt'),
            actualDuration: any(named: 'actualDuration'),
            completedAt: any(named: 'completedAt'),
            laborCost: any(named: 'laborCost'),
            maintenancePlanId: any(named: 'maintenancePlanId'),
            notes: any(named: 'notes'),
            partsCost: any(named: 'partsCost'),
            startedAt: any(named: 'startedAt'),
            totalCost: any(named: 'totalCost'),
            price: any(named: 'price'),
            currency: any(named: 'currency'),
            attachmentsCubit: any(named: 'attachmentsCubit'),
            serviceProviderCompanyId: any(named: 'serviceProviderCompanyId'),
            providerProfileId: any(named: 'providerProfileId'),
            slaPolicyId: any(named: 'slaPolicyId'),
            checklistTemplateId: any(named: 'checklistTemplateId'),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'when internalOnly: validates location requirement and submits with locationId',
      (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        // Fill title
        await tester.enterText(
          find.byType(EditableText).first,
          'Ordem Interna',
        );
        await tester.pumpAndSettle();

        // Tap save without selecting location
        await tester.tap(findSaveButton());
        await tester.pumpAndSettle();

        // Validation error appears
        expect(find.text('Selecione um local'), findsOneWidget);
        verifyNever(
          () => mockWorkOrdersCubit.saveWorkOrder(
            id: any(named: 'id'),
            isEditing: any(named: 'isEditing'),
            title: any(named: 'title'),
            priority: any(named: 'priority'),
            status: any(named: 'status'),
            type: any(named: 'type'),
          ),
        );

        // Select location
        await tester.tap(findDropdown('Location'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sede Principal').last);
        await tester.pumpAndSettle();

        // Tap save again
        await tester.tap(findSaveButton());
        await tester.pumpAndSettle();

        // Confirm dialog
        expect(find.text('Salvar alterações?'), findsOneWidget);
        final actionLocation = tester.widget<CupertinoDialogAction>(
          find.byType(CupertinoDialogAction).last,
        );
        actionLocation.onPressed!();
        await tester.pumpAndSettle();

        verify(
          () => mockWorkOrdersCubit.saveWorkOrder(
            id: any(named: 'id'),
            isEditing: false,
            locationId: 'location-1',
            workType: WorkType.internalOnly,
            areaId: any(named: 'areaId'),
            assetId: any(named: 'assetId'),
            assignedToId: any(named: 'assignedToId'),
            createdById: any(named: 'createdById'),
            createdByProviderProfileId: any(
              named: 'createdByProviderProfileId',
            ),
            openedBy: any(named: 'openedBy'),
            title: 'Ordem Interna',
            description: any(named: 'description'),
            priority: any(named: 'priority'),
            status: any(named: 'status'),
            type: any(named: 'type'),
            scheduledDate: any(named: 'scheduledDate'),
            estimatedDuration: any(named: 'estimatedDuration'),
            createdAt: any(named: 'createdAt'),
            actualDuration: any(named: 'actualDuration'),
            completedAt: any(named: 'completedAt'),
            laborCost: any(named: 'laborCost'),
            maintenancePlanId: any(named: 'maintenancePlanId'),
            notes: any(named: 'notes'),
            partsCost: any(named: 'partsCost'),
            startedAt: any(named: 'startedAt'),
            totalCost: any(named: 'totalCost'),
            price: any(named: 'price'),
            currency: any(named: 'currency'),
            attachmentsCubit: any(named: 'attachmentsCubit'),
            serviceProviderCompanyId: any(named: 'serviceProviderCompanyId'),
            providerProfileId: any(named: 'providerProfileId'),
            slaPolicyId: any(named: 'slaPolicyId'),
            checklistTemplateId: any(named: 'checklistTemplateId'),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'when serviceProviderOnly and customer selected, opens SearchableAssetPickerModal with customer and generic equipment',
      (tester) async {
        final custAsset = AssetFactory.makeAssetEntity().copyWith(
          id: 'asset-cust-1',
          name: 'Torno CNC Cliente',
          customerId: 'customer-1',
        );
        final genAsset = AssetFactory.makeAssetEntity().copyWith(
          id: 'asset-gen-1',
          name: 'Gerador Portátil',
          annulCustomerId: true,
        );
        final otherCustAsset = AssetFactory.makeAssetEntity().copyWith(
          id: 'asset-cust-2',
          name: 'Equipamento Outro Cliente',
          customerId: 'customer-other',
        );

        when(() => mockAssetsCubit.state).thenReturn(
          AssetsState(assets: [custAsset, genAsset, otherCustAsset]),
        );

        await tester.pumpWidget(
          buildWidget(workType: WorkType.serviceProviderOnly),
        );
        await tester.pumpAndSettle();

        // Initially no customer is selected
        expect(find.byKey(const ValueKey('Asset')), findsOneWidget);

        // Select customer
        await tester.tap(findDropdown('Customer'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cliente Teste').last);
        await tester.pumpAndSettle();

        // Tap asset picker
        await tester.tap(find.byKey(const ValueKey('Asset')));
        await tester.pumpAndSettle();

        // Modal should display customer equipment and generic equipment
        expect(find.text('Equipamentos do Cliente'), findsOneWidget);
        expect(find.text('Torno CNC Cliente'), findsOneWidget);
        expect(find.text('Equipamentos Gerais'), findsOneWidget);
        expect(find.text('Gerador Portátil'), findsOneWidget);
        // Other customer's asset should NOT be in the picker
        expect(find.text('Equipamento Outro Cliente'), findsNothing);

        // Select the customer asset
        await tester.tap(find.text('Torno CNC Cliente'));
        await tester.pumpAndSettle();

        // Form now displays selected asset name
        expect(find.text('Torno CNC Cliente'), findsOneWidget);
        expect(find.byKey(const ValueKey('AssetClearButton')), findsOneWidget);

        // Clear selection
        await tester.tap(find.byKey(const ValueKey('AssetClearButton')));
        await tester.pumpAndSettle();

        expect(find.text('Torno CNC Cliente'), findsNothing);
      },
    );

    testWidgets(
      'when serviceProviderOnly and no customer selected, modal only shows generic equipment',
      (tester) async {
        final custAsset = AssetFactory.makeAssetEntity().copyWith(
          id: 'asset-cust-1',
          name: 'Torno CNC Cliente',
          customerId: 'customer-1',
        );
        final genAsset = AssetFactory.makeAssetEntity().copyWith(
          id: 'asset-gen-1',
          name: 'Gerador Geral',
          annulCustomerId: true,
        );

        when(
          () => mockAssetsCubit.state,
        ).thenReturn(AssetsState(assets: [custAsset, genAsset]));

        await tester.pumpWidget(
          buildWidget(workType: WorkType.serviceProviderOnly),
        );
        await tester.pumpAndSettle();

        // Tap asset picker without selecting a customer
        await tester.tap(find.byKey(const ValueKey('Asset')));
        await tester.pumpAndSettle();

        // Should show generic equipment, but not customer equipment
        expect(find.text('Equipamentos Gerais'), findsOneWidget);
        expect(find.text('Gerador Geral'), findsOneWidget);
        expect(find.text('Torno CNC Cliente'), findsNothing);
      },
    );

    testWidgets(
      'when serviceProviderOnly and no assets exist, asset picker is disabled and tapping does not open modal',
      (tester) async {
        when(
          () => mockAssetsCubit.state,
        ).thenReturn(const AssetsState(assets: []));

        await tester.pumpWidget(
          buildWidget(workType: WorkType.serviceProviderOnly),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sem equipamentos cadastrados'), findsOneWidget);

        // Tap asset picker
        await tester.tap(find.byKey(const ValueKey('Asset')));
        await tester.pumpAndSettle();

        // Modal should NOT open
        expect(find.byType(SearchableAssetPickerModal), findsNothing);
      },
    );
  });
}
