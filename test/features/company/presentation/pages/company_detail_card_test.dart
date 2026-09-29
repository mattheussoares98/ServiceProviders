import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/company_detail_card.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';

import '../../../../../testing/mocks/factories/user_factory.dart';

class MockCompanyCubit extends MockCubit<CompanyState>
    implements CompanyCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockCompanyCubit mockCompanyCubit;
  late MockSessionCubit mockSessionCubit;

  setUp(() {
    mockCompanyCubit = MockCompanyCubit();
    mockSessionCubit = MockSessionCubit();

    when(() => mockCompanyCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCompanyCubit.state).thenReturn(const CompanyState.initial());

    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
    final user = UserFactory.makeUserProfileEntity().copyWith(isAdmin: false);
    when(
      () => mockSessionCubit.state,
    ).thenReturn(SessionState(user: user, isLoggedIn: true));
  });

  Widget buildWidget({required CompanyEntity company}) {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<CompanyCubit>.value(value: mockCompanyCubit),
            BlocProvider<SessionCubit>.value(value: mockSessionCubit),
          ],
          child: CompanyDetailCard(company: company),
        ),
      ),
    );
  }

  testWidgets('renders CNPJ format when document length is 14 digits', (
    tester,
  ) async {
    final company = UserFactory.makeCompanyEntity().copyWith(
      name: 'Empresa Teste',
      document: '12345678000199',
    );

    await tester.pumpWidget(buildWidget(company: company));

    expect(find.text('Empresa Teste'), findsOneWidget);
    expect(find.text('12.345.678/0001-99'), findsOneWidget);
  });

  testWidgets('renders CPF format when document length is 11 digits', (
    tester,
  ) async {
    final company = UserFactory.makeCompanyEntity().copyWith(
      name: 'Empresa CPF Teste',
      document: '12345678901',
    );

    await tester.pumpWidget(buildWidget(company: company));

    expect(find.text('Empresa CPF Teste'), findsOneWidget);
    expect(find.text('123.456.789-01'), findsOneWidget);
  });

  testWidgets('renders fallback text when document is null', (tester) async {
    final company = UserFactory.makeCompanyEntity().copyWith(
      name: 'Empresa Sem Doc',
      annulDocument: true,
    );

    await tester.pumpWidget(buildWidget(company: company));

    expect(find.text('Empresa Sem Doc'), findsOneWidget);
    expect(find.text('Documento não informado'), findsOneWidget);
  });
}
