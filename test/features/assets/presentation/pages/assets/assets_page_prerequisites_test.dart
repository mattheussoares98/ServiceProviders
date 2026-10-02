import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/assets/assets_page.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_empty_state.dart';

import '../../../../../../testing/mocks/factories/user_factory.dart';

class MockAssetsCubit extends MockCubit<AssetsState> implements AssetsCubit {}

class MockLocationsCubit extends MockCubit<LocationsState>
    implements LocationsCubit {}

class MockCompanyCubit extends MockCubit<CompanyState>
    implements CompanyCubit {}

class MockCustomersCubit extends MockCubit<CustomersState>
    implements CustomersCubit {}

class MockUsersCubit extends MockCubit<UsersState> implements UsersCubit {}

class MockCategoriesCubit extends MockCubit<CategoriesState>
    implements CategoriesCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const ActionPermission.resource(
        resourceType: ResourceType.assets,
        permissionAction: PermissionAction.create,
      ),
    );
  });

  late MockAssetsCubit mockAssetsCubit;
  late MockLocationsCubit mockLocationsCubit;
  late MockCompanyCubit mockCompanyCubit;
  late MockCustomersCubit mockCustomersCubit;
  late MockUsersCubit mockUsersCubit;
  late MockCategoriesCubit mockCategoriesCubit;
  late MockSessionCubit mockSessionCubit;

  setUp(() {
    mockAssetsCubit = MockAssetsCubit();
    mockLocationsCubit = MockLocationsCubit();
    mockCompanyCubit = MockCompanyCubit();
    mockCustomersCubit = MockCustomersCubit();
    mockUsersCubit = MockUsersCubit();
    mockCategoriesCubit = MockCategoriesCubit();
    mockSessionCubit = MockSessionCubit();

    when(() => mockAssetsCubit.loadAssets()).thenAnswer((_) async {});
    when(() => mockAssetsCubit.state).thenReturn(
      const AssetsState(
        assets: [],
        sections: {BaseSections.load: SectionState.success()},
      ),
    );
    when(
      () => mockLocationsCubit.state,
    ).thenReturn(const LocationsState.initial());
    when(
      () => mockCustomersCubit.state,
    ).thenReturn(const CustomersState.initial());
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
    when(
      () => mockCategoriesCubit.state,
    ).thenReturn(const CategoriesState.initial());
    when(() => mockSessionCubit.state).thenReturn(SessionState.initial());
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AssetsCubit>.value(value: mockAssetsCubit),
          BlocProvider<LocationsCubit>.value(value: mockLocationsCubit),
          BlocProvider<CompanyCubit>.value(value: mockCompanyCubit),
          BlocProvider<CustomersCubit>.value(value: mockCustomersCubit),
          BlocProvider<UsersCubit>.value(value: mockUsersCubit),
          BlocProvider<CategoriesCubit>.value(value: mockCategoriesCubit),
          BlocProvider<SessionCubit>.value(value: mockSessionCubit),
        ],
        child: const AssetsPage(),
      ),
    );
  }

  testWidgets('shows BaseEmptyState when internalOnly and zero locations', (
    tester,
  ) async {
    final company = UserFactory.makeCompanyEntity().copyWith(
      workType: WorkType.internalOnly,
    );
    when(
      () => mockCompanyCubit.state,
    ).thenReturn(CompanyState(company: company));

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    expect(find.byType(BaseEmptyState), findsOneWidget);
    expect(find.text('Cadastrar local'), findsOneWidget);
    expect(find.text('Cadastrar Local'), findsOneWidget);
  });

  testWidgets(
    'shows BaseEmptyState when serviceProviderOnly and zero customers',
    (tester) async {
      final company = UserFactory.makeCompanyEntity().copyWith(
        workType: WorkType.serviceProviderOnly,
      );
      when(
        () => mockCompanyCubit.state,
      ).thenReturn(CompanyState(company: company));

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(BaseEmptyState), findsOneWidget);
      expect(find.text('Cadastrar cliente'), findsOneWidget);
      expect(find.text('Cadastrar Cliente'), findsOneWidget);
    },
  );

  testWidgets(
    'shows normal empty text when hybrid and zero locations/customers',
    (tester) async {
      final company = UserFactory.makeCompanyEntity().copyWith(
        workType: WorkType.hybrid,
      );
      when(
        () => mockCompanyCubit.state,
      ).thenReturn(CompanyState(company: company));

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(BaseEmptyState), findsNothing);
      expect(find.text('Nenhum equipamento cadastrado'), findsOneWidget);
    },
  );
}
