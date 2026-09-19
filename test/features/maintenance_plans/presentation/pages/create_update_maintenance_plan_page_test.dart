import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/cubits/maintenance_plans/maintenance_plans_cubit.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/pages/create_update_maintenance_plan/create_update_maintenance_plan_page.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';

import '../../../../../testing/mocks/factories/maintenance_plan_factory.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';

class MockMaintenancePlansCubit extends MockCubit<MaintenancePlansState>
    implements MaintenancePlansCubit {}

class MockLocationsCubit extends MockCubit<LocationsState>
    implements LocationsCubit {}

class MockAssetsCubit extends MockCubit<AssetsState> implements AssetsCubit {}

class MockChecklistTemplatesCubit extends MockCubit<ChecklistTemplatesState>
    implements ChecklistTemplatesCubit {}

class MockServiceProvidersCubit extends MockCubit<ServiceProvidersState>
    implements ServiceProvidersCubit {}

class MockUsersCubit extends MockCubit<UsersState> implements UsersCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockScreenObserverCubit extends MockCubit<ScreenObserverState>
    implements ScreenObserverCubit {}

void main() {
  late MockMaintenancePlansCubit mockCubit;
  late MockLocationsCubit mockLocationsCubit;
  late MockAssetsCubit mockAssetsCubit;
  late MockChecklistTemplatesCubit mockChecklistCubit;
  late MockServiceProvidersCubit mockServiceProvidersCubit;
  late MockUsersCubit mockUsersCubit;
  late MockSessionCubit mockSessionCubit;
  late MockScreenObserverCubit mockScreenObserverCubit;

  setUpAll(() {
    registerFallbackValue(
      const ActionPermission.resource(
        resourceType: ResourceType.maintenancePlans,
        permissionAction: PermissionAction.read,
      ),
    );
    registerFallbackValue(MaintenancePlanFactory.makeMaintenancePlanEntity());
  });

  setUp(() {
    mockCubit = MockMaintenancePlansCubit();
    mockLocationsCubit = MockLocationsCubit();
    mockAssetsCubit = MockAssetsCubit();
    mockChecklistCubit = MockChecklistTemplatesCubit();
    mockServiceProvidersCubit = MockServiceProvidersCubit();
    mockUsersCubit = MockUsersCubit();
    mockSessionCubit = MockSessionCubit();
    mockScreenObserverCubit = MockScreenObserverCubit();

    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockLocationsCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockAssetsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockChecklistCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockServiceProvidersCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockScreenObserverCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      () => mockCubit.state,
    ).thenReturn(const MaintenancePlansState.initial());
    when(
      () => mockLocationsCubit.state,
    ).thenReturn(const LocationsState.initial());
    when(() => mockAssetsCubit.state).thenReturn(const AssetsState.initial());
    when(
      () => mockChecklistCubit.state,
    ).thenReturn(const ChecklistTemplatesState.initial());
    when(
      () => mockServiceProvidersCubit.state,
    ).thenReturn(const ServiceProvidersState.initial());
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
    when(
      () => mockScreenObserverCubit.state,
    ).thenReturn(ScreenObserverState.initial());
    when(() => mockSessionCubit.state).thenReturn(
      SessionState(user: UserFactory.makeUserProfileEntity(), isLoggedIn: true),
    );
    when(
      () => mockCubit.saveMaintenancePlan(any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockCubit.deleteMaintenancePlan(any()),
    ).thenAnswer((_) async => true);
  });

  Widget buildWidget({MaintenancePlanEntity? maintenancePlan}) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<MaintenancePlansCubit>.value(value: mockCubit),
          BlocProvider<LocationsCubit>.value(value: mockLocationsCubit),
          BlocProvider<AssetsCubit>.value(value: mockAssetsCubit),
          BlocProvider<ChecklistTemplatesCubit>.value(
            value: mockChecklistCubit,
          ),
          BlocProvider<ServiceProvidersCubit>.value(
            value: mockServiceProvidersCubit,
          ),
          BlocProvider<UsersCubit>.value(value: mockUsersCubit),
          BlocProvider<SessionCubit>.value(value: mockSessionCubit),
          BlocProvider<ScreenObserverCubit>.value(
            value: mockScreenObserverCubit,
          ),
        ],
        child: CreateUpdateMaintenancePlanPage(
          maintenancePlan: maintenancePlan,
        ),
      ),
    );
  }

  testWidgets('renders creation title when no plan provided', (tester) async {
    await tester.pumpWidget(buildWidget());

    expect(find.text('Criando plano de manutenção'), findsOneWidget);
    expect(find.text('Salvar plano'), findsOneWidget);
  });

  testWidgets('renders editing title and values when plan provided', (
    tester,
  ) async {
    final plan = MaintenancePlanFactory.makeMaintenancePlanEntity();

    await tester.pumpWidget(buildWidget(maintenancePlan: plan));

    expect(find.text('Editando plano de manutenção'), findsOneWidget);
    expect(find.text('Atualizar plano'), findsOneWidget);
    expect(find.text(plan.title), findsOneWidget);
  });

  testWidgets('submits the form when save button is pressed', (tester) async {
    final plan = MaintenancePlanFactory.makeMaintenancePlanEntity();

    await tester.pumpWidget(buildWidget(maintenancePlan: plan));
    await tester.ensureVisible(find.text('Atualizar plano'));
    await tester.tap(find.text('Atualizar plano'));
    await tester.pump();

    verify(() => mockCubit.saveMaintenancePlan(any())).called(1);
  });
}
