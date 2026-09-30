@Tags(['integration'])
library;

import 'package:bloc_test/bloc_test.dart';
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

import '../../../testing/mocks/factories/user_factory.dart';
import '../core/integration_cleanup.dart';
import '../core/integration_identity.dart';
import '../core/integration_permission_fixture.dart';
import '../core/integration_run.dart';
import '../core/integration_session.dart';
import '../helpers/live_ui_test_helper.dart';

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
  late IntegrationSession supervisor;
  late IntegrationSession provider;

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
    supervisor = await IntegrationSessions.as(Identity.supervisor);
    provider = await IntegrationSessions.as(Identity.provider);

    await PermissionFixture.recoverLedger(admin.database);
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
  });

  Widget buildPermissionWidget({
    required IntegrationSession session,
    required AppMode activeMode,
    required bool hasFinancialPermission,
  }) {
    LiveUiTestHelper.configureAppMode(activeMode);

    final mockCompanyCubit = _MockCompanyCubit();
    when(() => mockCompanyCubit.state).thenReturn(
      CompanyState(
        company: UserFactory.makeCompanyEntity().copyWith(
          id: session.companyId,
          workType: WorkType.internalOnly,
        ),
      ),
    );
    when(() => mockCompanyCubit.stream).thenAnswer((_) => const Stream.empty());

    final mockCustomersCubit = _MockCustomersCubit();
    when(
      () => mockCustomersCubit.state,
    ).thenReturn(const CustomersState.initial());
    when(
      () => mockCustomersCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    final mockLocationsCubit = _MockLocationsCubit();
    when(
      () => mockLocationsCubit.state,
    ).thenReturn(const LocationsState.initial());
    when(
      () => mockLocationsCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    final mockAssetsCubit = _MockAssetsCubit();
    when(() => mockAssetsCubit.state).thenReturn(const AssetsState.initial());
    when(() => mockAssetsCubit.stream).thenAnswer((_) => const Stream.empty());

    final mockUsersCubit = _MockUsersCubit();
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.hasPermission(any())).thenAnswer((invocation) {
      final perm = invocation.positionalArguments.first;
      if (perm ==
          const ActionPermission.workOrderSubAction(
            WorkOrderSubAction.manageFinancials,
          )) {
        return hasFinancialPermission;
      }
      return true;
    });

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

  group('Live UI Permissions and Default Groups Suite', () {
    testWidgets(
      'Role 1: Admin User has full editing controls and visible responsible assignment',
      (tester) async {
        LiveUiTestHelper.configureLiveTestEnvironment(tester);

        await tester.pumpWidget(
          buildPermissionWidget(
            session: admin,
            activeMode: AppMode.internal,
            hasFinancialPermission: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(findSaveButton(), findsOneWidget);
        expect(findDropdown('Responsible'), findsOneWidget);
        expect(find.byType(EditableText), findsWidgets);
      },
    );

    testWidgets(
      'Role 2: Supervisor User with full assignment rights has responsible dropdown visible',
      (tester) async {
        LiveUiTestHelper.configureLiveTestEnvironment(tester);

        await tester.pumpWidget(
          buildPermissionWidget(
            session: supervisor,
            activeMode: AppMode.internal,
            hasFinancialPermission: false,
          ),
        );
        await tester.pumpAndSettle();

        expect(findSaveButton(), findsOneWidget);
        expect(findDropdown('Responsible'), findsOneWidget);
      },
    );

    testWidgets(
      'Role 3: Technician User acting in internal mode can create order with responsible assignment',
      (tester) async {
        LiveUiTestHelper.configureLiveTestEnvironment(tester);

        await tester.pumpWidget(
          buildPermissionWidget(
            session: tech,
            activeMode: AppMode.internal,
            hasFinancialPermission: false,
          ),
        );
        await tester.pumpAndSettle();

        expect(findSaveButton(), findsOneWidget);
        expect(findDropdown('Responsible'), findsOneWidget);
      },
    );

    testWidgets(
      'Role 4: Service Provider User in AppMode.provider has internal assignment restricted',
      (tester) async {
        LiveUiTestHelper.configureLiveTestEnvironment(tester);

        await tester.pumpWidget(
          buildPermissionWidget(
            session: provider,
            activeMode: AppMode.provider,
            hasFinancialPermission: false,
          ),
        );
        await tester.pumpAndSettle();

        // In provider mode, internal responsible assignment and 3rd party hiring are hidden
        expect(findDropdown('Responsible'), findsNothing);
        expect(findDropdown('ServiceProviderCompany'), findsNothing);

        // Core fields are editable when creating an order
        expect(findSaveButton(), findsOneWidget);
        expect(find.byType(EditableText), findsWidgets);
      },
    );

    testWidgets(
      'Role 5: Viewer User with applied Read-Only Permission Fixture',
      (tester) async {
        LiveUiTestHelper.configureLiveTestEnvironment(tester);

        // Apply read-only fixture to technician's session in the real database
        await PermissionFixture.apply(
          session: tech,
          permissions: {
            'work_orders': ['read'],
          },
          label: 'viewer-test',
        );

        await tester.pumpWidget(
          buildPermissionWidget(
            session: tech,
            activeMode: AppMode.internal,
            hasFinancialPermission: false,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CreateUpdateWorkOrderPage), findsOneWidget);
      },
    );
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
