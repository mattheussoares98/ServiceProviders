import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/pages/create_update_customer/create_update_customer_page.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/pages/create_update_customer/widgets/customer_delete_button.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/address_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/themes/theme.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

import '../../../../../testing/mocks/cubits/customers_mocks.dart';
import '../../../../../testing/mocks/factories/customer_factory.dart';

void main() {
  late MockCustomersCubit mockCubit;

  void formTest(String description, WidgetTesterCallback callback) {
    testWidgets(
      description,
      callback,
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  }

  setUp(() {
    mockCubit = MockCustomersCubit();
    const screenDetails = ScreenDetails(
      logicalSize: Size(1920, 1280),
      physicalSize: Size(1920, 1280),
      devicePixelRatio: 1,
    );
    ScreenUtil.I.configureScreen(screenDetails);

    when(
      () => mockCubit.state,
    ).thenReturn(const CustomersState(customers: []));
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    when(
      () => mockCubit.saveCustomer(
        id: any(named: 'id'),
        name: any(named: 'name'),
        document: any(named: 'document'),
        contactName: any(named: 'contactName'),
        contactEmail: any(named: 'contactEmail'),
        contactPhone: any(named: 'contactPhone'),
        postalCode: any(named: 'postalCode'),
        address: any(named: 'address'),
        number: any(named: 'number'),
        complement: any(named: 'complement'),
        neighborhood: any(named: 'neighborhood'),
        city: any(named: 'city'),
        stateAddress: any(named: 'stateAddress'),
        notes: any(named: 'notes'),
        isActive: any(named: 'isActive'),
        createdAt: any(named: 'createdAt'),
      ),
    ).thenAnswer((_) async => true);

    when(() => mockCubit.deleteCustomer(any())).thenAnswer((_) async => true);
    when(() => mockCubit.getAddressByCep(any())).thenAnswer((_) async => null);
  });

  Widget buildTestWidget({CustomerEntity? customer}) {
    return BlocProvider<CustomersCubit>.value(
      value: mockCubit,
      child: MaterialApp(
        theme: lightTheme,
        home: CreateUpdateCustomerPage(customer: customer),
      ),
    );
  }

  formTest('renders create mode with title "Novo cliente" and no delete button', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Novo cliente'), findsOneWidget);
    expect(find.byType(CustomerDeleteButton), findsNothing);
    expect(find.text('Salvar'), findsOneWidget);
  });

  formTest('renders edit mode with title "Editando cliente" and delete button', (
    tester,
  ) async {
    final customer = CustomerFactory.makeCustomerEntity().copyWith(
      name: 'Existing Customer Inc',
      document: '12345678901',
    );

    await tester.pumpWidget(buildTestWidget(customer: customer));
    await tester.pumpAndSettle();

    expect(find.text('Editando cliente'), findsOneWidget);
    expect(find.byType(CustomerDeleteButton), findsOneWidget);
    expect(find.text('Existing Customer Inc'), findsOneWidget);
  });

  formTest('validates required name field before saving', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Campo obrigatório'), findsOneWidget);
    verifyNever(
      () => mockCubit.saveCustomer(
        id: any(named: 'id'),
        name: any(named: 'name'),
        document: any(named: 'document'),
        contactName: any(named: 'contactName'),
        contactEmail: any(named: 'contactEmail'),
        contactPhone: any(named: 'contactPhone'),
        postalCode: any(named: 'postalCode'),
        address: any(named: 'address'),
        number: any(named: 'number'),
        complement: any(named: 'complement'),
        neighborhood: any(named: 'neighborhood'),
        city: any(named: 'city'),
        stateAddress: any(named: 'stateAddress'),
        notes: any(named: 'notes'),
        isActive: any(named: 'isActive'),
        createdAt: any(named: 'createdAt'),
      ),
    );
  });

  formTest('submits form when name is provided', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'New Customer Ltd',
    );

    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    verify(
      () => mockCubit.saveCustomer(
        id: null,
        name: 'New Customer Ltd',
        document: any(named: 'document'),
        contactName: any(named: 'contactName'),
        contactEmail: any(named: 'contactEmail'),
        contactPhone: any(named: 'contactPhone'),
        postalCode: any(named: 'postalCode'),
        address: any(named: 'address'),
        number: any(named: 'number'),
        complement: any(named: 'complement'),
        neighborhood: any(named: 'neighborhood'),
        city: any(named: 'city'),
        stateAddress: any(named: 'stateAddress'),
        notes: any(named: 'notes'),
        isActive: any(named: 'isActive'),
        createdAt: any(named: 'createdAt'),
      ),
    ).called(1);
  });

  formTest(
    'clicking delete button opens confirmation dialog and confirms deletion',
    (tester) async {
      final customer = CustomerFactory.makeCustomerEntity().copyWith(
        name: 'To Delete Customer',
      );

      await tester.pumpWidget(buildTestWidget(customer: customer));
      await tester.pumpAndSettle();

      final deleteButton = find.byType(CustomerDeleteButton);
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.byKey(kDialogDefaultKey), findsOneWidget);
      expect(find.text('Atenção!'), findsOneWidget);
      expect(
        find.text('Deseja realmente excluir o cliente "To Delete Customer"?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Sim'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.deleteCustomer(customer.id)).called(1);
    },
  );

  formTest('entering 8-digit CEP calls getAddressByCep and autofills address', (
    tester,
  ) async {
    const address = AddressEntity(
      postalCode: '01310100',
      street: 'Av Paulista',
      neighborhood: 'Bela Vista',
      city: 'São Paulo',
      state: 'SP',
    );

    when(
      () => mockCubit.getAddressByCep('01310100'),
    ).thenAnswer((_) async => address);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // CEP is the 6th text form field in the form:
    // 0: Name, 1: CPF/CNPJ, 2: Contact Name, 3: Contact Email, 4: Contact Phone, 5: Notes, 6: CEP
    // Or find by label text:
    final cepField = find.widgetWithText(TextFormField, 'CEP');
    await tester.ensureVisible(cepField);
    await tester.enterText(cepField, '01310100');
    await tester.pumpAndSettle();

    verify(() => mockCubit.getAddressByCep('01310100')).called(1);
  });
}
