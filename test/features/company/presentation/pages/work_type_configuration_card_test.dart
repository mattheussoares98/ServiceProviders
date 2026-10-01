import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/company/widgets/work_type_configuration_card.dart';
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
  late CompanyEntity tCompany;

  setUpAll(() {
    registerFallbackValue(WorkType.internalOnly);
  });

  setUp(() {
    mockCompanyCubit = MockCompanyCubit();
    mockSessionCubit = MockSessionCubit();

    tCompany = UserFactory.makeCompanyEntity().copyWith(
      workType: WorkType.internalOnly,
    );

    when(
      () => mockCompanyCubit.state,
    ).thenReturn(CompanyState(company: tCompany));

    final adminUser = UserFactory.makeUserProfileEntity().copyWith(
      isAdmin: true,
    );
    when(
      () => mockSessionCubit.state,
    ).thenReturn(SessionState(user: adminUser, isLoggedIn: true));
  });

  Widget buildSubject({CompanyEntity? company}) {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<CompanyCubit>.value(value: mockCompanyCubit),
            BlocProvider<SessionCubit>.value(value: mockSessionCubit),
          ],
          child: WorkTypeConfigurationCard(company: company ?? tCompany),
        ),
      ),
    );
  }

  testWidgets('renders all 3 work type options with labels', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Modelo de operação'), findsOneWidget);
    expect(find.text('Interno'), findsOneWidget);
    expect(find.text('Prestador de serviços'), findsOneWidget);
    expect(find.text('Ambos'), findsOneWidget);
  });

  testWidgets(
    'admin tapping hybrid option shows confirmation dialog and invokes updateWorkType when confirmed',
    (tester) async {
      when(
        () => mockCompanyCubit.updateWorkType(any()),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(buildSubject());

      final hybridOption = find.byKey(const ValueKey('WorkTypeOption_hybrid'));
      expect(hybridOption, findsOneWidget);

      await tester.tap(hybridOption);
      await tester.pumpAndSettle();

      expect(find.text('Alterar modelo de operação'), findsOneWidget);

      // Locate the confirm CupertinoDialogAction and invoke onPressed directly
      // because tester.tap doesn't reliably trigger the callback chain
      // through AlertDialog.adaptive in the FakeAsync test environment
      final confirmFinder = find.widgetWithText(
        CupertinoDialogAction,
        'Confirmar',
      );
      expect(confirmFinder, findsOneWidget);
      final action = tester.widget<CupertinoDialogAction>(confirmFinder);
      action.onPressed!();
      await tester.pumpAndSettle();

      verify(() => mockCompanyCubit.updateWorkType(WorkType.hybrid)).called(1);
    },
  );

  testWidgets(
    'admin cancelling confirmation dialog does not invoke updateWorkType',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      final hybridOption = find.byKey(const ValueKey('WorkTypeOption_hybrid'));
      await tester.tap(hybridOption);
      await tester.pumpAndSettle();

      final cancelAction = find.byWidgetPredicate(
        (widget) =>
            (widget is CupertinoDialogAction || widget is TextButton) &&
            find
                .descendant(
                  of: find.byWidget(widget),
                  matching: find.text('Cancelar'),
                )
                .evaluate()
                .isNotEmpty,
      );
      expect(cancelAction, findsOneWidget);

      await tester.tap(cancelAction);
      await tester.pumpAndSettle();

      verifyNever(() => mockCompanyCubit.updateWorkType(any()));
    },
  );

  testWidgets(
    'admin cannot tap serviceProviderOnly option when current is internalOnly',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(
          company: tCompany.copyWith(workType: WorkType.internalOnly),
        ),
      );

      final providerOption = find.byKey(
        const ValueKey('WorkTypeOption_service_provider_only'),
      );
      await tester.tap(providerOption);
      await tester.pumpAndSettle();

      verifyNever(() => mockCompanyCubit.updateWorkType(any()));
      expect(find.text('Alterar modelo de operação'), findsNothing);
    },
  );

  testWidgets(
    'admin cannot tap internalOnly option when current is serviceProviderOnly',
    (tester) async {
      final providerCompany = tCompany.copyWith(
        workType: WorkType.serviceProviderOnly,
      );
      when(
        () => mockCompanyCubit.state,
      ).thenReturn(CompanyState(company: providerCompany));

      await tester.pumpWidget(buildSubject(company: providerCompany));

      final internalOption = find.byKey(
        const ValueKey('WorkTypeOption_internal_only'),
      );
      await tester.tap(internalOption);
      await tester.pumpAndSettle();

      verifyNever(() => mockCompanyCubit.updateWorkType(any()));
      expect(find.text('Alterar modelo de operação'), findsNothing);
    },
  );

  testWidgets(
    'non-admin tapping unselected option does not invoke updateWorkType',
    (tester) async {
      final regularUser = UserFactory.makeUserProfileEntity().copyWith(
        isAdmin: false,
      );
      when(
        () => mockSessionCubit.state,
      ).thenReturn(SessionState(user: regularUser, isLoggedIn: true));

      await tester.pumpWidget(buildSubject());

      final hybridOption = find.byKey(const ValueKey('WorkTypeOption_hybrid'));
      await tester.tap(hybridOption);
      await tester.pumpAndSettle();

      verifyNever(() => mockCompanyCubit.updateWorkType(any()));
    },
  );

  testWidgets('shows loading circle when updateWorkType is running', (
    tester,
  ) async {
    when(() => mockCompanyCubit.state).thenReturn(
      CompanyState(
        company: tCompany,
        sections: const {
          CompanySections.updateWorkType: SectionState.running(),
        },
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.byType(LoadingCircle), findsOneWidget);
  });
}
