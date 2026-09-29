import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
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
import '../../../../../../testing/mocks/factories/service_provider_factory.dart';
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
  final tArea = AssetFactory.makeAreaEntity().copyWith(
    id: 'area-1',
    name: 'Setor 1',
    locationId: 'location-1',
  );
  final tServiceProvider =
      ServiceProviderFactory.makeServiceProviderCompanyEntity().copyWith(
    id: 'sp-company-1',
    name: 'Eletro Prestadora',
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

    const screenDetails = ScreenDetails(
      logicalSize: Size(1920, 1280),
      physicalSize: Size(1920, 1280),
      devicePixelRatio: 1,
    );
    ScreenUtil.I.configureScreen(screenDetails);

    when(() => mockWorkOrdersCubit.state)
        .thenReturn(const WorkOrdersState.initial());
    when(() => mockWorkOrdersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockWorkOrdersCubit.realtimeEvents)
        .thenAnswer((_) => const Stream<RealtimeEvent<WorkOrderEntity>>.empty());

    when(() => mockCompanyCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCustomersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockLocationsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAssetsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockServiceProvidersCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockChecklistCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSlaPoliciesCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAttachmentsCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockCustomersCubit.state)
        .thenReturn(CustomersState(customers: [tCustomer]));
    when(() => mockLocationsCubit.state).thenReturn(
      LocationsState(
        locations: [tLocation],
        areasByLocation: {
          'location-1': [tArea],
        },
        allAreas: [tArea],
      ),
    );
    when(() => mockAssetsCubit.state).thenReturn(const AssetsState.initial());
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
    when(() => mockServiceProvidersCubit.state).thenReturn(
      ServiceProvidersState(
        companies: [tServiceProvider],
        profiles: const {},
      ),
    );
    when(() => mockChecklistCubit.state)
        .thenReturn(const ChecklistTemplatesState.initial());
    when(() => mockSlaPoliciesCubit.state)
        .thenReturn(const SlaPoliciesState.initial());
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

  Widget buildMatrixWidget({
    required WorkType workType,
    required AppMode activeMode,
    String? workOrderId,
  }) {
    when(() => mockGetSelectedMode.call()).thenReturn(activeMode.name);

    when(() => mockCompanyCubit.state).thenReturn(
      CompanyState(
        company: UserFactory.makeCompanyEntity().copyWith(workType: workType),
      ),
    );

    when(() => mockSessionCubit.state).thenReturn(
      SessionState(
        user: UserFactory.makeUserProfileEntity(),
        isLoggedIn: true,
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
          workOrderId: workOrderId,
          attachmentsCubit: mockAttachmentsCubit,
        ),
      ),
    );
  }

  Future<void> pumpMatrix(
    WidgetTester tester, {
    required WorkType workType,
    required AppMode activeMode,
    String? workOrderId,
  }) async {
    tester.view.physicalSize = const Size(1920, 1280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      buildMatrixWidget(
        workType: workType,
        activeMode: activeMode,
        workOrderId: workOrderId,
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder findDropdown(String key) => find.byWidgetPredicate(
        (w) =>
            (w is BaseDropDown<String> || w is BaseDropDown<String?>) &&
            w.key == ValueKey(key),
      );

  Finder findSaveButton() => find.byType(BaseIconButton).last;

  group('WorkType and User Mode Combinations Matrix', () {
    group('1. Internal-Only User (acting in AppMode.internal)', () {
      testWidgets(
        'Combination 1A: Internal User + WorkType.internalOnly '
        '-> shows Location/Area, hides Customer, validates Location is required',
        (tester) async {
          await pumpMatrix(
            tester,
            workType: WorkType.internalOnly,
            activeMode: AppMode.internal,
          );

          // Field visibility
          expect(findDropdown('Location'), findsOneWidget);
          expect(findDropdown('Area'), findsOneWidget);
          expect(findDropdown('Customer'), findsNothing);

          // Can hire service providers (provider dropdown visible)
          expect(findDropdown('ServiceProviderCompany'), findsOneWidget);

          // Validation requires Location
          await tester.enterText(
            find.byType(EditableText).first,
            'Ordem Interna Teste',
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
        'Combination 1B: Internal User + WorkType.serviceProviderOnly '
        '-> shows Customer, hides Location/Area, hides ServiceProvider, validates Customer is required',
        (tester) async {
          await pumpMatrix(
            tester,
            workType: WorkType.serviceProviderOnly,
            activeMode: AppMode.internal,
          );

          // Field visibility
          expect(findDropdown('Customer'), findsOneWidget);
          expect(findDropdown('Location'), findsNothing);
          expect(findDropdown('Area'), findsNothing);

          // Cannot hire service providers
          expect(findDropdown('ServiceProviderCompany'), findsNothing);

          // Validation requires Customer
          await tester.enterText(
            find.byType(EditableText).first,
            'Ordem Prestador Teste',
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
        'Combination 1C: Internal User + WorkType.hybrid '
        '-> shows Customer, Location, Area, and ServiceProvider dropdowns',
        (tester) async {
          await pumpMatrix(
            tester,
            workType: WorkType.hybrid,
            activeMode: AppMode.internal,
          );

          // All fields visible
          expect(findDropdown('Customer'), findsOneWidget);
          expect(findDropdown('Location'), findsOneWidget);
          expect(findDropdown('Area'), findsOneWidget);
          expect(findDropdown('ServiceProviderCompany'), findsOneWidget);

          // Enter title and submit without selecting Customer or Location (both optional in hybrid)
          await tester.enterText(
            find.byType(EditableText).first,
            'Ordem Híbrida Teste',
          );
          await tester.pumpAndSettle();

          await tester.tap(findSaveButton());
          await tester.pumpAndSettle();

          // Shows confirm dialog because required fields are satisfied
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
              title: 'Ordem Híbrida Teste',
              priority: any(named: 'priority'),
              status: any(named: 'status'),
              type: any(named: 'type'),
              areaId: any(named: 'areaId'),
              assetId: any(named: 'assetId'),
              assignedToId: any(named: 'assignedToId'),
              createdById: any(named: 'createdById'),
              createdByProviderProfileId: any(named: 'createdByProviderProfileId'),
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
              description: any(named: 'description'),
            ),
          ).called(1);
        },
      );
    });

    group('2. Service Provider User in Provider Mode (acting in AppMode.provider)', () {
      testWidgets(
        'Combination 2A: Provider Mode + WorkType.internalOnly '
        '-> operates in facility mode, hides Customer, restricts SLA and provider assignment',
        (tester) async {
          await pumpMatrix(
            tester,
            workType: WorkType.internalOnly,
            activeMode: AppMode.provider,
          );

          // Operates in facility mode
          expect(findDropdown('Location'), findsOneWidget);
          expect(findDropdown('Area'), findsOneWidget);
          expect(findDropdown('Customer'), findsNothing);

          // Provider cannot assign provider company or SLA policy
          expect(findDropdown('ServiceProviderCompany'), findsNothing);
          expect(findDropdown('SlaPolicy'), findsNothing);
        },
      );

      testWidgets(
        'Combination 2B: Provider Mode + WorkType.serviceProviderOnly '
        '-> overrides company serviceProviderOnly, forces facility mode (shows Location/Area, hides Customer)',
        (tester) async {
          await pumpMatrix(
            tester,
            workType: WorkType.serviceProviderOnly,
            activeMode: AppMode.provider,
          );

          // Provider mode forces facility mode regardless of company workType
          expect(findDropdown('Location'), findsOneWidget);
          expect(findDropdown('Area'), findsOneWidget);
          expect(findDropdown('Customer'), findsNothing);
          expect(findDropdown('ServiceProviderCompany'), findsNothing);
        },
      );

      testWidgets(
        'Combination 2C: Provider Mode + WorkType.hybrid '
        '-> forces facility mode and restricts provider assignment',
        (tester) async {
          await pumpMatrix(
            tester,
            workType: WorkType.hybrid,
            activeMode: AppMode.provider,
          );

          expect(findDropdown('Location'), findsOneWidget);
          expect(findDropdown('Area'), findsOneWidget);
          expect(findDropdown('Customer'), findsNothing);
          expect(findDropdown('ServiceProviderCompany'), findsNothing);
        },
      );

      testWidgets(
        'Combination 2D: Provider Mode submits with openedBy == AppMode.provider',
        (tester) async {
          await pumpMatrix(
            tester,
            workType: WorkType.internalOnly,
            activeMode: AppMode.provider,
          );

          await tester.enterText(
            find.byType(EditableText).first,
            'Ordem Aberta por Prestador',
          );
          await tester.pumpAndSettle();

          // Select location
          await tester.tap(findDropdown('Location'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Sede Principal').last);
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
              title: 'Ordem Aberta por Prestador',
              locationId: 'location-1',
              priority: any(named: 'priority'),
              status: any(named: 'status'),
              type: any(named: 'type'),
              areaId: any(named: 'areaId'),
              assetId: any(named: 'assetId'),
              assignedToId: any(named: 'assignedToId'),
              createdById: any(named: 'createdById'),
              createdByProviderProfileId: any(named: 'createdByProviderProfileId'),
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
              description: any(named: 'description'),
            ),
          ).called(1);
        },
      );
    });

    group('3. Dual User (Service Provider too, acting in AppMode.internal)', () {
      testWidgets(
        'Combination 3A: Dual User in Internal Mode + WorkType.serviceProviderOnly '
        '-> restores full customer dropdown and customer validation',
        (tester) async {
          await pumpMatrix(
            tester,
            workType: WorkType.serviceProviderOnly,
            activeMode: AppMode.internal,
          );

          expect(findDropdown('Customer'), findsOneWidget);
          expect(findDropdown('Location'), findsNothing);
          expect(findDropdown('Area'), findsNothing);
        },
      );

      testWidgets(
        'Combination 3B: Dual User in Internal Mode + WorkType.hybrid '
        '-> restores all dropdowns and internal assignment capabilities',
        (tester) async {
          await pumpMatrix(
            tester,
            workType: WorkType.hybrid,
            activeMode: AppMode.internal,
          );

          expect(findDropdown('Customer'), findsOneWidget);
          expect(findDropdown('Location'), findsOneWidget);
          expect(findDropdown('Area'), findsOneWidget);
          expect(findDropdown('ServiceProviderCompany'), findsOneWidget);
        },
      );
    });
  });
}
