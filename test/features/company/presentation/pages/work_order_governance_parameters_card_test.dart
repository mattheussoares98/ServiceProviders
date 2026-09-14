import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/work_order_governance_parameters_card.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_switch.dart';

import '../../../../../testing/mocks/factories/user_factory.dart';

class MockCompanyCubit extends MockCubit<CompanyState>
    implements CompanyCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockCompanyCubit mockCompanyCubit;
  late MockSessionCubit mockSessionCubit;
  late CompanyParameterEntity tParameters;

  setUp(() {
    mockCompanyCubit = MockCompanyCubit();
    mockSessionCubit = MockSessionCubit();

    tParameters = UserFactory.makeCompanyParameterEntity().copyWith(
      allowProviderCreateWorkOrder: false,
    );

    when(() => mockCompanyCubit.state).thenReturn(
      CompanyState(parameters: tParameters),
    );

    final adminUser = UserFactory.makeUserProfileEntity().copyWith(
      isAdmin: true,
    );
    when(
      () => mockSessionCubit.state,
    ).thenReturn(SessionState(user: adminUser, isLoggedIn: true));
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<CompanyCubit>.value(value: mockCompanyCubit),
            BlocProvider<SessionCubit>.value(value: mockSessionCubit),
          ],
          child: WorkOrderGovernanceParametersCard(parameters: tParameters),
        ),
      ),
    );
  }

  testWidgets('renders toggle and reverts value on failure', (tester) async {
    when(
      () => mockCompanyCubit.updateAllowProviderCreateWorkOrder(true),
    ).thenAnswer((_) async => false);

    await tester.pumpWidget(buildSubject());

    final switchFinder = find.byType(BaseSwitch);
    expect(switchFinder, findsOneWidget);

    final switchWidget = tester.widget<BaseSwitch>(switchFinder);
    expect(switchWidget.value, isFalse);

    // Tap switch to turn ON
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    verify(
      () => mockCompanyCubit.updateAllowProviderCreateWorkOrder(true),
    ).called(1);

    // Because update failed, the toggle reverts back to false
    final revertedWidget = tester.widget<BaseSwitch>(switchFinder);
    expect(revertedWidget.value, isFalse);
  });

  testWidgets('renders toggle and keeps new value on success', (tester) async {
    when(
      () => mockCompanyCubit.updateAllowProviderCreateWorkOrder(true),
    ).thenAnswer((_) async => true);

    await tester.pumpWidget(buildSubject());

    final switchFinder = find.byType(BaseSwitch);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    verify(
      () => mockCompanyCubit.updateAllowProviderCreateWorkOrder(true),
    ).called(1);

    final updatedWidget = tester.widget<BaseSwitch>(switchFinder);
    expect(updatedWidget.value, isTrue);
  });
}
