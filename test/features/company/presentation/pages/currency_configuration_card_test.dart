import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/currency_configuration_card.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';

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
      currency: 'BRL',
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

  Widget buildSubject({CompanyParameterEntity? parameters}) {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<CompanyCubit>.value(value: mockCompanyCubit),
            BlocProvider<SessionCubit>.value(value: mockSessionCubit),
          ],
          child: CurrencyConfigurationCard(
            parameters: parameters ?? tParameters,
          ),
        ),
      ),
    );
  }

  testWidgets('renders all 3 currency options with labels', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Moeda padrão'), findsOneWidget);
    expect(find.text(r'BRL (R$)'), findsOneWidget);
    expect(find.text(r'USD ($)'), findsOneWidget);
    expect(find.text('EUR (€)'), findsOneWidget);
  });

  testWidgets('admin tapping unselected option invokes updateCurrency', (
    tester,
  ) async {
    when(
      () => mockCompanyCubit.updateCurrency(any()),
    ).thenAnswer((_) async => true);

    await tester.pumpWidget(buildSubject());

    final usdOption = find.byKey(const ValueKey('CurrencyOption_USD'));
    expect(usdOption, findsOneWidget);

    await tester.tap(usdOption);
    await tester.pumpAndSettle();

    verify(() => mockCompanyCubit.updateCurrency('USD')).called(1);
  });

  testWidgets(
    'non-admin tapping unselected option does not invoke updateCurrency',
    (tester) async {
      final regularUser = UserFactory.makeUserProfileEntity().copyWith(
        isAdmin: false,
      );
      when(
        () => mockSessionCubit.state,
      ).thenReturn(SessionState(user: regularUser, isLoggedIn: true));

      await tester.pumpWidget(buildSubject());

      final usdOption = find.byKey(const ValueKey('CurrencyOption_USD'));
      await tester.tap(usdOption);
      await tester.pumpAndSettle();

      verifyNever(() => mockCompanyCubit.updateCurrency(any()));
    },
  );

  testWidgets('shows loading circle when updateCurrency is running', (
    tester,
  ) async {
    when(() => mockCompanyCubit.state).thenReturn(
      CompanyState(
        parameters: tParameters,
        sections: const {
          CompanySections.updateCurrency: SectionState.running(),
        },
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.byType(LoadingCircle), findsOneWidget);
  });
}
