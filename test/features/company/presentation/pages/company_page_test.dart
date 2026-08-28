import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/company_page.dart';
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
  late StreamController<CompanyState> companyStreamController;

  setUp(() {
    mockCompanyCubit = MockCompanyCubit();
    mockSessionCubit = MockSessionCubit();
    companyStreamController = StreamController<CompanyState>.broadcast();

    when(
      () => mockCompanyCubit.stream,
    ).thenAnswer((_) => companyStreamController.stream);
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());

    final adminUser = EntityFactory.makeUserProfileEntity().copyWith(
      isAdmin: true,
      email: 'mattheussbarosa98@gmail.com',
    );
    when(
      () => mockSessionCubit.state,
    ).thenReturn(SessionState(user: adminUser, isLoggedIn: true));
  });

  tearDown(() {
    companyStreamController.close();
  });

  Widget buildWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<CompanyCubit>.value(value: mockCompanyCubit),
          BlocProvider<SessionCubit>.value(value: mockSessionCubit),
        ],
        child: const CompanyPage(),
      ),
    );
  }

  testWidgets('renders loaded state with company and parameters', (
    tester,
  ) async {
    final company = EntityFactory.makeCompanyEntity();
    final params = EntityFactory.makeCompanyParameterEntity();

    when(() => mockCompanyCubit.state).thenReturn(
      CompanyState(
        status: StateStatus.loaded,
        company: company,
        companies: [company],
        parameters: params,
      ),
    );

    await tester.pumpWidget(buildWidget());

    expect(find.text('Empresa'), findsOneWidget);
    expect(find.text(company.name), findsOneWidget);
  });

  testWidgets('shows loading overlay when switchCompany section is loading', (
    tester,
  ) async {
    final company = EntityFactory.makeCompanyEntity();
    final initialState = CompanyState(
      status: StateStatus.loaded,
      company: company,
      companies: [company],
    );

    when(() => mockCompanyCubit.state).thenReturn(initialState);

    await tester.pumpWidget(buildWidget());
    expect(find.text('Aguarde'), findsNothing);

    final loadingState = initialState.copyWith(
      sections: {CompanySection.switchCompany: StateStatus.loading},
    );
    when(() => mockCompanyCubit.state).thenReturn(loadingState);
    companyStreamController.add(loadingState);
    await tester.pump();

    expect(find.text('Aguarde'), findsOneWidget);

    final loadedState = initialState.copyWith(
      sections: {CompanySection.switchCompany: StateStatus.loaded},
    );
    when(() => mockCompanyCubit.state).thenReturn(loadedState);
    companyStreamController.add(loadedState);
    await tester.pump();

    expect(find.text('Aguarde'), findsNothing);
  });

  testWidgets(
    'shows loading overlay when updateEscalationParameters section is loading',
    (tester) async {
      final company = EntityFactory.makeCompanyEntity();
      final params = EntityFactory.makeCompanyParameterEntity();
      final initialState = CompanyState(
        status: StateStatus.loaded,
        company: company,
        companies: [company],
        parameters: params,
      );

      when(() => mockCompanyCubit.state).thenReturn(initialState);

      await tester.pumpWidget(buildWidget());
      expect(find.text('Aguarde'), findsNothing);

      final loadingState = initialState.copyWith(
        sections: {
          CompanySection.updateEscalationParameters: StateStatus.loading,
        },
      );
      when(() => mockCompanyCubit.state).thenReturn(loadingState);
      companyStreamController.add(loadingState);
      await tester.pump();

      expect(find.text('Aguarde'), findsOneWidget);

      final loadedState = initialState.copyWith(
        sections: {
          CompanySection.updateEscalationParameters: StateStatus.loaded,
        },
      );
      when(() => mockCompanyCubit.state).thenReturn(loadedState);
      companyStreamController.add(loadedState);
      await tester.pump();

      expect(find.text('Aguarde'), findsNothing);
    },
  );
}
