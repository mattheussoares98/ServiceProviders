@Tags(['integration'])
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
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
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/create_update_work_order_page.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';

import '../../../testing/mocks/factories/asset_factory.dart';
import '../../../testing/mocks/factories/customer_factory.dart';
import '../../../testing/mocks/factories/user_factory.dart';
import '../core/integration_cleanup.dart';
import '../core/integration_company_work_type_fixture.dart';
import '../core/integration_identity.dart';
import '../core/integration_run.dart';
import '../core/integration_session.dart';
import '../helpers/asset_integration_helper.dart';
import '../helpers/category_integration_helper.dart';
import '../helpers/customer_integration_helper.dart';
import '../helpers/live_ui_test_helper.dart';
import '../helpers/location_integration_helper.dart';
import '../helpers/sla_integration_helper.dart';

class _MockWorkOrdersCubit extends MockCubit<WorkOrdersState>
    implements WorkOrdersCubit {}

class _MockAttachmentsCubit extends MockCubit<AttachmentsState>
    implements AttachmentsCubit {}

class _MockChecklistTemplatesCubit extends MockCubit<ChecklistTemplatesState>
    implements ChecklistTemplatesCubit {}

class _MockSlaPoliciesCubit extends MockCubit<SlaPoliciesState>
    implements SlaPoliciesCubit {}

void main() {
  if (!IntegrationRun.registerGuard()) return;

  late IntegrationSession admin;
  late IntegrationSession tech;
  late IntegrationSession provider;

  late String locationId;
  late String areaId;
  late String customerId;
  late String customerName;
  late String locationName;

  late _MockWorkOrdersCubit mockWorkOrdersCubit;
  late _MockAttachmentsCubit mockAttachmentsCubit;
  late _MockChecklistTemplatesCubit mockChecklistCubit;
  late _MockSlaPoliciesCubit mockSlaCubit;

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

  setUpAll(() async {
    admin = await IntegrationSessions.as(Identity.admin);
    tech = await IntegrationSessions.as(Identity.technician);
    provider = await IntegrationSessions.as(Identity.provider);

    final sources = admin.sources;
    final companyId = admin.companyId;

    final location = await LocationIntegrationHelper.getOrCreateLocation(
      sources.locations,
      companyId,
    );
    locationId = location.id;
    locationName = location.name;

    final area = await LocationIntegrationHelper.getOrCreateArea(
      sources.locations,
      companyId,
      locationId,
    );
    areaId = area.id;

    final category = await CategoryIntegrationHelper.getOrCreateCategory(
      sources.categories,
      companyId,
    );

    await AssetIntegrationHelper.getOrCreateAsset(
      assetsRemote: sources.assets,
      locationsRemote: sources.locations,
      companyId: companyId,
      areaId: areaId,
      categoryId: category.id,
    );

    await SlaIntegrationHelper.getOrCreateSlaPolicy(sources.sla, companyId);

    final customer = await CustomerIntegrationHelper.getOrCreateCustomer(
      sources.customers,
      companyId,
    );
    customerId = customer.id;
    customerName = customer.name;
  });

  tearDownAll(() async {
    await IntegrationCleanup.cleanTracked(admin.database);
    await IntegrationSessions.disposeAll();
  });

  setUp(() {
    mockWorkOrdersCubit = _MockWorkOrdersCubit();
    mockAttachmentsCubit = _MockAttachmentsCubit();
    mockChecklistCubit = _MockChecklistTemplatesCubit();
    mockSlaCubit = _MockSlaPoliciesCubit();

    when(
      () => mockWorkOrdersCubit.state,
    ).thenReturn(const WorkOrdersState.initial());
    when(
      () => mockWorkOrdersCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(() => mockAttachmentsCubit.state).thenReturn(
      const AttachmentsState(
        sections: {BaseSections.load: SectionState.success()},
      ),
    );
    when(
      () => mockAttachmentsCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      () => mockChecklistCubit.state,
    ).thenReturn(const ChecklistTemplatesState.initial());
    when(
      () => mockChecklistCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(() => mockSlaCubit.state).thenReturn(const SlaPoliciesState.initial());
    when(() => mockSlaCubit.stream).thenAnswer((_) => const Stream.empty());

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

  Widget buildLiveWidget({
    required IntegrationSession session,
    required WorkType workType,
    required AppMode activeMode,
  }) {
    LiveUiTestHelper.configureAppMode(activeMode);

    final mockCompanyCubit = _MockCompanyCubit();
    when(() => mockCompanyCubit.state).thenReturn(
      CompanyState(
        company: UserFactory.makeCompanyEntity().copyWith(
          id: session.companyId,
          workType: workType,
        ),
      ),
    );
    when(() => mockCompanyCubit.stream).thenAnswer((_) => const Stream.empty());

    final mockCustomersCubit = _MockCustomersCubit();
    when(() => mockCustomersCubit.state).thenReturn(
      CustomersState(
        customers: [
          CustomerFactory.makeCustomerEntity().copyWith(
            id: customerId,
            companyId: session.companyId,
            name: customerName,
            isActive: true,
          ),
        ],
      ),
    );
    when(
      () => mockCustomersCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    final mockLocationsCubit = _MockLocationsCubit();
    final realLocation = AssetFactory.makeLocationEntity().copyWith(
      id: locationId,
      companyId: session.companyId,
      name: locationName,
    );
    final realArea = AssetFactory.makeAreaEntity().copyWith(
      id: areaId,
      locationId: locationId,
      name: 'Área Principal',
    );
    when(() => mockLocationsCubit.state).thenReturn(
      LocationsState(
        locations: [realLocation],
        areasByLocation: {
          locationId: [realArea],
        },
        allAreas: [realArea],
      ),
    );
    when(
      () => mockLocationsCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    final mockAssetsCubit = _MockAssetsCubit();
    when(() => mockAssetsCubit.state).thenReturn(const AssetsState.initial());
    when(() => mockAssetsCubit.stream).thenAnswer((_) => const Stream.empty());

    final mockUsersCubit = _MockUsersCubit();
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);

    final mockProvidersCubit = _MockServiceProvidersCubit();
    when(
      () => mockProvidersCubit.state,
    ).thenReturn(const ServiceProvidersState(companies: [], profiles: {}));
    when(
      () => mockProvidersCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    final mockSessionCubit = _MockSessionCubit();
    when(() => mockSessionCubit.state).thenReturn(
      SessionState(
        user: UserFactory.makeUserProfileEntity().copyWith(
          id: session.userId,
          companyId: session.companyId,
        ),
        isLoggedIn: true,
      ),
    );
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<WorkOrdersCubit>.value(value: mockWorkOrdersCubit),
          BlocProvider<CompanyCubit>.value(value: mockCompanyCubit),
          BlocProvider<CustomersCubit>.value(value: mockCustomersCubit),
          BlocProvider<LocationsCubit>.value(value: mockLocationsCubit),
          BlocProvider<AssetsCubit>.value(value: mockAssetsCubit),
          BlocProvider<UsersCubit>.value(value: mockUsersCubit),
          BlocProvider<ServiceProvidersCubit>.value(value: mockProvidersCubit),
          BlocProvider<ChecklistTemplatesCubit>.value(
            value: mockChecklistCubit,
          ),
          BlocProvider<SlaPoliciesCubit>.value(value: mockSlaCubit),
          BlocProvider<SessionCubit>.value(value: mockSessionCubit),
        ],
        child: CreateUpdateWorkOrderPage(
          attachmentsCubit: mockAttachmentsCubit,
        ),
      ),
    );
  }

  Finder findDropdown(String key) => find.byWidgetPredicate(
    (w) =>
        (w is BaseDropDown<String> || w is BaseDropDown<String?>) &&
        w.key == ValueKey(key),
  );

  Finder findSaveButton() => find.byType(BaseIconButton).last;

  group('Live UI Work Orders Matrix Suite (Real Database & Sessions)', () {
    testWidgets(
      'Live Case 1: WorkType.internalOnly with Admin Session '
      '-> renders live location/area, hides customer, enforces location validation',
      (tester) async {
        LiveUiTestHelper.configureLiveTestEnvironment(tester);
        await CompanyWorkTypeFixture.apply(
          adminSession: admin,
          workType: WorkType.internalOnly,
        );

        await tester.pumpWidget(
          buildLiveWidget(
            session: admin,
            workType: WorkType.internalOnly,
            activeMode: AppMode.internal,
          ),
        );
        await tester.pumpAndSettle();

        expect(findDropdown('Location'), findsOneWidget);
        expect(findDropdown('Area'), findsOneWidget);
        expect(findDropdown('Customer'), findsNothing);

        await tester.enterText(
          find.byType(EditableText).first,
          'Live Internal Order',
        );
        await tester.pumpAndSettle();

        await tester.tap(findSaveButton());
        await tester.pumpAndSettle();

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
      },
    );

    testWidgets(
      'Live Case 2: WorkType.serviceProviderOnly with Internal Session '
      '-> renders live customer, hides location/area, enforces customer validation',
      (tester) async {
        LiveUiTestHelper.configureLiveTestEnvironment(tester);
        await CompanyWorkTypeFixture.apply(
          adminSession: admin,
          workType: WorkType.serviceProviderOnly,
        );

        await tester.pumpWidget(
          buildLiveWidget(
            session: tech,
            workType: WorkType.serviceProviderOnly,
            activeMode: AppMode.internal,
          ),
        );
        await tester.pumpAndSettle();

        expect(findDropdown('Customer'), findsOneWidget);
        expect(findDropdown('Location'), findsNothing);
        expect(findDropdown('Area'), findsNothing);

        await tester.enterText(
          find.byType(EditableText).first,
          'Live Provider Order',
        );
        await tester.pumpAndSettle();

        await tester.tap(findSaveButton());
        await tester.pumpAndSettle();

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
      },
    );

    testWidgets(
      'Live Case 3: WorkType.hybrid with Internal Session '
      '-> renders both customer and location/area, submits without customer/location requirement',
      (tester) async {
        LiveUiTestHelper.configureLiveTestEnvironment(tester);
        await CompanyWorkTypeFixture.apply(
          adminSession: admin,
          workType: WorkType.hybrid,
        );

        await tester.pumpWidget(
          buildLiveWidget(
            session: admin,
            workType: WorkType.hybrid,
            activeMode: AppMode.internal,
          ),
        );
        await tester.pumpAndSettle();

        expect(findDropdown('Customer'), findsOneWidget);
        expect(findDropdown('Location'), findsOneWidget);
        expect(findDropdown('Area'), findsOneWidget);

        await tester.enterText(
          find.byType(EditableText).first,
          'Live Hybrid Order',
        );
        await tester.pumpAndSettle();

        await tester.tap(findSaveButton());
        await tester.pumpAndSettle();

        expect(find.text('Salvar alterações?'), findsOneWidget);
        final action = tester.widget<CupertinoDialogAction>(
          find.byType(CupertinoDialogAction).last,
        );
        action.onPressed!();
        await tester.pumpAndSettle();

        verify(
          () => mockWorkOrdersCubit.saveWorkOrder(
            id: any(named: 'id'),
            isEditing: false,
            workType: WorkType.hybrid,
            title: 'Live Hybrid Order',
            priority: any(named: 'priority'),
            status: any(named: 'status'),
            type: any(named: 'type'),
            areaId: any(named: 'areaId'),
            assetId: any(named: 'assetId'),
            assignedToId: any(named: 'assignedToId'),
            createdById: any(named: 'createdById'),
            createdByProviderProfileId: any(
              named: 'createdByProviderProfileId',
            ),
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
            customerId: any(named: 'customerId'),
            locationId: any(named: 'locationId'),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'Live Case 4: Service Provider Session in AppMode.provider '
      '-> forces facility mode regardless of company workType, submits with openedBy == provider',
      (tester) async {
        LiveUiTestHelper.configureLiveTestEnvironment(tester);

        await tester.pumpWidget(
          buildLiveWidget(
            session: provider,
            workType: WorkType.serviceProviderOnly,
            activeMode: AppMode.provider,
          ),
        );
        await tester.pumpAndSettle();

        expect(findDropdown('Location'), findsOneWidget);
        expect(findDropdown('Area'), findsOneWidget);
        expect(findDropdown('Customer'), findsNothing);

        await tester.enterText(
          find.byType(EditableText).first,
          'Live Provider Mode Order',
        );
        await tester.pumpAndSettle();

        await tester.tap(findDropdown('Location'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(locationName).last);
        await tester.pumpAndSettle();

        await tester.tap(findSaveButton());
        await tester.pumpAndSettle();

        expect(find.text('Salvar alterações?'), findsOneWidget);
        final action = tester.widget<CupertinoDialogAction>(
          find.byType(CupertinoDialogAction).last,
        );
        action.onPressed!();
        await tester.pumpAndSettle();

        verify(
          () => mockWorkOrdersCubit.saveWorkOrder(
            id: any(named: 'id'),
            isEditing: false,
            openedBy: AppMode.provider,
            workType: WorkType.internalOnly,
            title: 'Live Provider Mode Order',
            locationId: locationId,
            priority: any(named: 'priority'),
            status: any(named: 'status'),
            type: any(named: 'type'),
            areaId: any(named: 'areaId'),
            assetId: any(named: 'assetId'),
            assignedToId: any(named: 'assignedToId'),
            createdById: any(named: 'createdById'),
            createdByProviderProfileId: any(
              named: 'createdByProviderProfileId',
            ),
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
            customerId: any(named: 'customerId'),
          ),
        ).called(1);
      },
    );

    testWidgets('Live Case 5: Dual User in AppMode.internal '
        '-> restores internal customer/location capabilities', (tester) async {
      final session = tech;
      LiveUiTestHelper.configureLiveTestEnvironment(tester);
      await CompanyWorkTypeFixture.apply(
        adminSession: admin,
        workType: WorkType.serviceProviderOnly,
      );

      await tester.pumpWidget(
        buildLiveWidget(
          session: session,
          workType: WorkType.serviceProviderOnly,
          activeMode: AppMode.internal,
        ),
      );
      await tester.pumpAndSettle();

      expect(findDropdown('Customer'), findsOneWidget);
      expect(findDropdown('Location'), findsNothing);
      expect(findDropdown('Area'), findsNothing);
    });
  });
}

class _MockCompanyCubit extends MockCubit<CompanyState>
    implements CompanyCubit {}

class _MockCustomersCubit extends MockCubit<CustomersState>
    implements CustomersCubit {}

class _MockLocationsCubit extends MockCubit<LocationsState>
    implements LocationsCubit {}

class _MockAssetsCubit extends MockCubit<AssetsState> implements AssetsCubit {}

class _MockUsersCubit extends MockCubit<UsersState> implements UsersCubit {}

class _MockServiceProvidersCubit extends MockCubit<ServiceProvidersState>
    implements ServiceProvidersCubit {}

class _MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}
