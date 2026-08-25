import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/escalation_parameters_card.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';

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
        status: StateStatus.loaded,
        parameters: tParameters,
        permissionGroups: tGroups,
      ),
    );

    final adminUser = EntityFactory.makeUserProfileEntity().copyWith(
      isAdmin: true,
    );
    when(() => mockSessionCubit.state).thenReturn(
      SessionState(
        user: adminUser,
        isLoggedIn: true,
      ),
    );
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

    expect(find.text('Escalonamento & Avisos de SLA'), findsOneWidget);
    expect(find.text('Aviso Prévio de Vencimento'), findsOneWidget);
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
}
