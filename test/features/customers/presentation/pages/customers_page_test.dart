import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/pages/customers/customers_page.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/pages/customers/widgets/customer_card.dart';
import 'package:o_jogo_da_obra/features/home/presentation/widgets/open_drawer_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/themes/theme.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

import '../../../../../testing/mocks/cubits/customers_mocks.dart';
import '../../../../../testing/mocks/factories/customer_factory.dart';

void main() {
  late MockCustomersCubit mockCubit;

  setUp(() {
    mockCubit = MockCustomersCubit();
    const screenDetails = ScreenDetails(
      logicalSize: Size(1920, 1280),
      physicalSize: Size(1920, 1280),
      devicePixelRatio: 1,
    );
    ScreenUtil.I.configureScreen(screenDetails);

    when(() => mockCubit.loadCustomers()).thenAnswer((_) async {});
    when(
      () => mockCubit.navigateToCreateUpdateCustomer(
        customer: any(named: 'customer'),
      ),
    ).thenAnswer((_) async {});
  });

  Widget buildTestWidget({
    List<CustomerEntity> customers = const [],
    SectionState loadSection = const SectionState.success(),
    bool? hasCustomers,
  }) {
    final state = CustomersState(
      customers: customers,
      hasCustomers: hasCustomers ?? customers.isNotEmpty,
      sections: {BaseSections.load: loadSection},
    );

    when(() => mockCubit.state).thenReturn(state);
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    return BlocProvider<CustomersCubit>.value(
      value: mockCubit,
      child: MaterialApp(theme: lightTheme, home: const CustomersPage()),
    );
  }

  testWidgets('renders empty message when customer list is empty', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(customers: []));
    await tester.pump();

    expect(find.text('Nenhum cliente cadastrado'), findsOneWidget);
    expect(find.byType(CustomerCard), findsNothing);
  });

  testWidgets('renders customer list and cards when customers exist', (
    tester,
  ) async {
    final customers = [
      CustomerFactory.makeCustomerEntity().copyWith(name: 'Alpha Corp'),
      CustomerFactory.makeCustomerEntity().copyWith(name: 'Beta Services'),
    ];

    await tester.pumpWidget(buildTestWidget(customers: customers));
    await tester.pump();

    expect(find.text('Alpha Corp'), findsOneWidget);
    expect(find.text('Beta Services'), findsOneWidget);
    expect(find.byType(CustomerCard), findsNWidgets(2));
  });

  testWidgets(
    'calls navigateToCreateUpdateCustomer when add button is tapped',
    (tester) async {
      await tester.pumpWidget(buildTestWidget(customers: []));
      await tester.pump();

      final addIcon = find.byWidgetPredicate(
        (w) =>
            w is Icon && (w.icon == Icons.add || w.icon == CupertinoIcons.add),
      );
      expect(addIcon, findsOneWidget);

      await tester.tap(addIcon);
      await tester.pump();

      verify(() => mockCubit.navigateToCreateUpdateCustomer()).called(1);
    },
  );

  testWidgets(
    'calls navigateToCreateUpdateCustomer with customer when card is tapped',
    (tester) async {
      final customer = CustomerFactory.makeCustomerEntity().copyWith(
        name: 'Alpha Corp',
      );

      await tester.pumpWidget(buildTestWidget(customers: [customer]));
      await tester.pump();

      await tester.tap(find.text('Alpha Corp'));
      await tester.pump();

      verify(
        () => mockCubit.navigateToCreateUpdateCustomer(customer: customer),
      ).called(1);
    },
  );

  testWidgets('renders OpenDrawerIconButton as leading widget in AppBar', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(customers: []));
    await tester.pump();

    expect(find.byType(OpenDrawerIconButton), findsOneWidget);
  });
}
