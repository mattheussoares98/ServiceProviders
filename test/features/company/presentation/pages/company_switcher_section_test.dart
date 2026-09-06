import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/company_switcher_section.dart';

import '../../../../../testing/mocks/factories/user_factory.dart';

class MockCompanyCubit extends Mock implements CompanyCubit {}

void main() {
  late MockCompanyCubit mockCubit;

  setUp(() {
    mockCubit = MockCompanyCubit();
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.state).thenReturn(const CompanyState.initial());
  });

  Widget buildWidget({
    required List<CompanyEntity> companies,
    required String? selectedCompanyId,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<CompanyCubit>.value(
          value: mockCubit,
          child: CompanySwitcherSection(
            companies: companies,
            selectedCompanyId: selectedCompanyId,
          ),
        ),
      ),
    );
  }

  testWidgets('renders companies and highlights selected company', (
    tester,
  ) async {
    final companies = UserFactory.makeCompanyEntityList();
    final selectedId = companies.first.id;

    await tester.pumpWidget(
      buildWidget(companies: companies, selectedCompanyId: selectedId),
    );

    expect(find.text('Alternar Empresa'), findsOneWidget);
    expect(find.text(companies[0].name), findsOneWidget);
    expect(find.text(companies[1].name), findsOneWidget);
    expect(find.text(companies[2].name), findsOneWidget);
    expect(find.text('Ativa'), findsOneWidget);
  });

  testWidgets('tapping non-selected company calls switchCompany', (
    tester,
  ) async {
    final companies = UserFactory.makeCompanyEntityList();
    final selectedId = companies.first.id;
    when(() => mockCubit.switchCompany(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      buildWidget(companies: companies, selectedCompanyId: selectedId),
    );

    await tester.tap(find.text(companies[1].name));
    await tester.pump();

    verify(() => mockCubit.switchCompany(companies[1].id)).called(1);
  });
}
