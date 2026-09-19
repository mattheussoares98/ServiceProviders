import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/cubits/maintenance_plans/maintenance_plans_cubit.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/pages/maintenance_plans/maintenance_plans_page.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';

import '../../../../../testing/mocks/factories/maintenance_plan_factory.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';

class MockMaintenancePlansCubit extends MockCubit<MaintenancePlansState>
    implements MaintenancePlansCubit {}

class MockUsersCubit extends MockCubit<UsersState> implements UsersCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockMaintenancePlansCubit mockCubit;
  late MockUsersCubit mockUsersCubit;
  late MockSessionCubit mockSessionCubit;

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
    mockUsersCubit = MockUsersCubit();
    mockSessionCubit = MockSessionCubit();

    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
    when(() => mockSessionCubit.state).thenReturn(
      SessionState(user: UserFactory.makeUserProfileEntity(), isLoggedIn: true),
    );
    when(() => mockCubit.loadMaintenancePlans()).thenAnswer((_) async {});
    when(
      () => mockCubit.navigateToCreateUpdateMaintenancePlan(
        maintenancePlan: any(named: 'maintenancePlan'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockCubit.toggleActive(any())).thenAnswer((_) async => true);
    when(
      () => mockCubit.deleteMaintenancePlan(any()),
    ).thenAnswer((_) async => true);
  });

  Widget buildWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<MaintenancePlansCubit>.value(value: mockCubit),
          BlocProvider<UsersCubit>.value(value: mockUsersCubit),
          BlocProvider<SessionCubit>.value(value: mockSessionCubit),
        ],
        child: const MaintenancePlansPage(),
      ),
    );
  }

  void stubState(List<MaintenancePlanEntity> plans) {
    when(() => mockCubit.state).thenReturn(
      MaintenancePlansState(
        maintenancePlans: plans,
        sections: const {BaseSections.load: SectionState.success()},
      ),
    );
  }

  testWidgets('renders empty message when no maintenance plans exist', (
    tester,
  ) async {
    stubState(const []);

    await tester.pumpWidget(buildWidget());

    expect(find.text('Planos de manutenção'), findsOneWidget);
    expect(find.text('Nenhum plano de manutenção cadastrado'), findsOneWidget);
  });

  testWidgets('renders plan cards when plans exist', (tester) async {
    final plans = MaintenancePlanFactory.makeMaintenancePlanEntityList();
    stubState(plans);

    await tester.pumpWidget(buildWidget());

    for (final plan in plans) {
      expect(find.text(plan.title), findsOneWidget);
    }
  });

  testWidgets('tapping a plan navigates to create/update page', (tester) async {
    final plan = MaintenancePlanFactory.makeMaintenancePlanEntity();
    stubState([plan]);

    await tester.pumpWidget(buildWidget());
    await tester.tap(find.text(plan.title));
    await tester.pump();

    verify(
      () => mockCubit.navigateToCreateUpdateMaintenancePlan(
        maintenancePlan: plan,
      ),
    ).called(1);
  });

  testWidgets('displays error warning banner when lastError is present', (
    tester,
  ) async {
    final plan = MaintenancePlanFactory.makeMaintenancePlanEntity().copyWith(
      lastError: 'Falha ao processar template',
    );
    stubState([plan]);

    await tester.pumpWidget(buildWidget());

    expect(
      find.text('Falha na última geração: Falha ao processar template'),
      findsOneWidget,
    );
  });
}
