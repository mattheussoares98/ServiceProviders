import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/escalation_parameters_card/escalation_parameters_card.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';

import '../../../../../testing/mocks/entity_factory.dart';

class MockCompanyCubit extends MockCubit<CompanyState>
    implements CompanyCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockCompanyCubit mockCompanyCubit;
  late MockSessionCubit mockSessionCubit;
  late CompanyParameterEntity tParameters;
  late List<PermissionGroupEntity> tGroups;

  setUp(() {
    mockCompanyCubit = MockCompanyCubit();
    mockSessionCubit = MockSessionCubit();

    tParameters = EntityFactory.makeCompanyParameterEntity().copyWith(
      advanceWarningMinutes: 30,
      delayedNotificationIntervalMinutes: 45,
      advanceWarningGroupIds: ['grp-1'],
      escalationGroupIds: ['grp-1', 'grp-2'],
    );

    tGroups = [
      EntityFactory.makePermissionGroupEntity().copyWith(
        id: 'grp-1',
        name: 'Supervisores',
      ),
      EntityFactory.makePermissionGroupEntity().copyWith(
        id: 'grp-2',
        name: 'Gerentes',
      ),
      EntityFactory.makePermissionGroupEntity().copyWith(
        id: 'grp-3',
        name: 'Diretoria',
      ),
    ];

    when(() => mockCompanyCubit.state).thenReturn(
      CompanyState(
        status: DataStatus.loaded,
        parameters: tParameters,
        permissionGroups: tGroups,
      ),
    );

    final adminUser = EntityFactory.makeUserProfileEntity().copyWith(
      isAdmin: true,
    );
    when(
      () => mockSessionCubit.state,
    ).thenReturn(SessionState(user: adminUser, isLoggedIn: true));
  });

  Widget buildWidget({
    required CompanyParameterEntity parameters,
    required List<PermissionGroupEntity> permissionGroups,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<CompanyCubit>.value(value: mockCompanyCubit),
            BlocProvider<SessionCubit>.value(value: mockSessionCubit),
          ],
          child: SingleChildScrollView(
            child: EscalationParametersCard(
              parameters: parameters,
              permissionGroups: permissionGroups,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders fields and group chips properly', (tester) async {
    await tester.pumpWidget(
      buildWidget(parameters: tParameters, permissionGroups: tGroups),
    );

    expect(find.text('Escalonamento & avisos de SLA'), findsOneWidget);
    expect(find.text('Aviso prévio de vencimento'), findsOneWidget);
    expect(find.text('Supervisores'), findsWidgets);
    expect(find.text('Gerentes'), findsWidgets);
    expect(find.text('Salvar parâmetros de escalonamento'), findsOneWidget);
  });

  testWidgets('tapping save calls updateEscalationParameters on cubit', (
    tester,
  ) async {
    when(
      () => mockCompanyCubit.updateEscalationParameters(
        advanceWarningMinutes: any(named: 'advanceWarningMinutes'),
        advanceWarningGroupIds: any(named: 'advanceWarningGroupIds'),
        delayedNotificationIntervalMinutes: any(
          named: 'delayedNotificationIntervalMinutes',
        ),
        escalationGroupIds: any(named: 'escalationGroupIds'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      buildWidget(parameters: tParameters, permissionGroups: tGroups),
    );

    final saveButton = find.text('Salvar parâmetros de escalonamento');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();

    await tester.tap(saveButton);
    await tester.pump();

    verify(
      () => mockCompanyCubit.updateEscalationParameters(
        advanceWarningMinutes: 30,
        advanceWarningGroupIds: ['grp-1'],
        delayedNotificationIntervalMinutes: 45,
        escalationGroupIds: ['grp-1', 'grp-2'],
      ),
    ).called(1);
  });

  testWidgets(
    'toggling advance group chip updates advanceWarningGroupIds on save',
    (tester) async {
      when(
        () => mockCompanyCubit.updateEscalationParameters(
          advanceWarningMinutes: any(named: 'advanceWarningMinutes'),
          advanceWarningGroupIds: any(named: 'advanceWarningGroupIds'),
          delayedNotificationIntervalMinutes: any(
            named: 'delayedNotificationIntervalMinutes',
          ),
          escalationGroupIds: any(named: 'escalationGroupIds'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildWidget(parameters: tParameters, permissionGroups: tGroups),
      );

      // Toggle 'Gerentes' in advance warning chips
      final gerentesChip = find.widgetWithText(FilterChip, 'Gerentes');
      await tester.ensureVisible(gerentesChip);
      await tester.tap(gerentesChip);
      await tester.pumpAndSettle();

      final saveButton = find.text('Salvar parâmetros de escalonamento');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      verify(
        () => mockCompanyCubit.updateEscalationParameters(
          advanceWarningMinutes: 30,
          advanceWarningGroupIds: ['grp-1', 'grp-2'],
          delayedNotificationIntervalMinutes: 45,
          escalationGroupIds: ['grp-1', 'grp-2'],
        ),
      ).called(1);
    },
  );

  testWidgets('removing escalation group updates escalationGroupIds on save', (
    tester,
  ) async {
    when(
      () => mockCompanyCubit.updateEscalationParameters(
        advanceWarningMinutes: any(named: 'advanceWarningMinutes'),
        advanceWarningGroupIds: any(named: 'advanceWarningGroupIds'),
        delayedNotificationIntervalMinutes: any(
          named: 'delayedNotificationIntervalMinutes',
        ),
        escalationGroupIds: any(named: 'escalationGroupIds'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      buildWidget(parameters: tParameters, permissionGroups: tGroups),
    );

    // Remove first group in escalation hierarchy
    final deleteButtons = find.byType(BaseIconButton);
    expect(deleteButtons, findsNWidgets(2));
    await tester.ensureVisible(deleteButtons.first);
    await tester.pumpAndSettle();
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    final saveButton = find.text('Salvar parâmetros de escalonamento');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    verify(
      () => mockCompanyCubit.updateEscalationParameters(
        advanceWarningMinutes: 30,
        advanceWarningGroupIds: ['grp-1'],
        delayedNotificationIntervalMinutes: 45,
        escalationGroupIds: ['grp-2'],
      ),
    ).called(1);
  });

  testWidgets('renders read-only mode for non-admin users', (tester) async {
    final regularUser = EntityFactory.makeUserProfileEntity().copyWith(
      isAdmin: false,
    );
    when(
      () => mockSessionCubit.state,
    ).thenReturn(SessionState(user: regularUser, isLoggedIn: true));

    await tester.pumpWidget(
      buildWidget(parameters: tParameters, permissionGroups: tGroups),
    );

    expect(find.text('Salvar parâmetros de escalonamento'), findsNothing);
    expect(find.byType(BaseIconButton), findsNothing);
    expect(find.byIcon(Icons.add_circle_outline), findsNothing);
  });
}
