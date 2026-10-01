import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/widgets/orders_items.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/prerequisites/prerequisite_guide_card.dart';

import '../../../../../../testing/mocks/factories/asset_factory.dart';
import '../../../../../../testing/mocks/factories/user_factory.dart';

class MockWorkOrdersCubit extends MockCubit<WorkOrdersState>
    implements WorkOrdersCubit {}

class MockLocationsCubit extends MockCubit<LocationsState>
    implements LocationsCubit {}

class MockCompanyCubit extends MockCubit<CompanyState>
    implements CompanyCubit {}

class MockCustomersCubit extends MockCubit<CustomersState>
    implements CustomersCubit {}

class MockAssetsCubit extends MockCubit<AssetsState>
    implements AssetsCubit {}

class MockUsersCubit extends MockCubit<UsersState>
    implements UsersCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const ActionPermission.resource(
        resourceType: ResourceType.locations,
        permissionAction: PermissionAction.create,
      ),
    );
  });

  late MockWorkOrdersCubit mockWorkOrdersCubit;
  late MockLocationsCubit mockLocationsCubit;
  late MockCompanyCubit mockCompanyCubit;
  late MockCustomersCubit mockCustomersCubit;
  late MockAssetsCubit mockAssetsCubit;
  late MockUsersCubit mockUsersCubit;
  late MockSessionCubit mockSessionCubit;

  setUp(() {
    mockWorkOrdersCubit = MockWorkOrdersCubit();
    mockLocationsCubit = MockLocationsCubit();
    mockCompanyCubit = MockCompanyCubit();
    mockCustomersCubit = MockCustomersCubit();
    mockAssetsCubit = MockAssetsCubit();
    mockUsersCubit = MockUsersCubit();
    mockSessionCubit = MockSessionCubit();

    when(() => mockWorkOrdersCubit.state).thenReturn(
      const WorkOrdersState(
        workOrders: [],
        changeRequests: [],
        sections: {BaseSections.load: SectionState.success()},
      ),
    );
    when(() => mockWorkOrdersCubit.loadWorkOrdersAndChangeRequests())
        .thenAnswer((_) async => true);
    when(() => mockLocationsCubit.state)
        .thenReturn(const LocationsState.initial());
    when(() => mockCompanyCubit.state)
        .thenReturn(const CompanyState.initial());
    when(() => mockCustomersCubit.state)
        .thenReturn(const CustomersState.initial());
    when(() => mockAssetsCubit.state)
        .thenReturn(const AssetsState.initial());
    when(() => mockUsersCubit.state)
        .thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(true);
    when(() => mockSessionCubit.state).thenReturn(SessionState.initial());
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<WorkOrdersCubit>.value(value: mockWorkOrdersCubit),
            BlocProvider<LocationsCubit>.value(value: mockLocationsCubit),
            BlocProvider<CompanyCubit>.value(value: mockCompanyCubit),
            BlocProvider<CustomersCubit>.value(value: mockCustomersCubit),
            BlocProvider<AssetsCubit>.value(value: mockAssetsCubit),
            BlocProvider<UsersCubit>.value(value: mockUsersCubit),
            BlocProvider<SessionCubit>.value(value: mockSessionCubit),
          ],
          child: const OrdersItems(),
        ),
      ),
    );
  }

  testWidgets(
    'shows PrerequisiteGuideCard when internalOnly and locations missing',
    (tester) async {
      final company = UserFactory.makeCompanyEntity().copyWith(
        workType: WorkType.internalOnly,
      );
      when(() => mockCompanyCubit.state).thenReturn(
        CompanyState(company: company),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PrerequisiteGuideCard), findsOneWidget);
      expect(find.text('Cadastrar Local'), findsOneWidget);
    },
  );

  testWidgets(
    'shows PrerequisiteGuideCard when serviceProviderOnly and customers missing',
    (tester) async {
      final company = UserFactory.makeCompanyEntity().copyWith(
        workType: WorkType.serviceProviderOnly,
      );
      when(() => mockCompanyCubit.state).thenReturn(
        CompanyState(company: company),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PrerequisiteGuideCard), findsOneWidget);
      expect(find.text('Cadastrar Cliente'), findsOneWidget);
    },
  );

  testWidgets(
    'shows default empty state when prerequisites are satisfied but no orders exist',
    (tester) async {
      final company = UserFactory.makeCompanyEntity().copyWith(
        workType: WorkType.internalOnly,
      );
      when(() => mockCompanyCubit.state).thenReturn(
        CompanyState(company: company),
      );
      final loc = AssetFactory.makeLocationEntity();
      when(() => mockLocationsCubit.state).thenReturn(
        LocationsState(
          locations: [loc],
          allAreas: const [],
          areasByLocation: const {},
          hasLocations: true,
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PrerequisiteGuideCard), findsNothing);
      expect(find.text('Nenhuma ordem foi encontrada'), findsOneWidget);
    },
  );

  testWidgets(
    'shows default empty state when filter is active even if prerequisites missing',
    (tester) async {
      when(() => mockWorkOrdersCubit.state).thenReturn(
        const WorkOrdersState(
          workOrders: [],
          changeRequests: [],
          activeFilter: WorkOrderFilter(searchText: 'teste'),
          sections: {BaseSections.load: SectionState.success()},
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PrerequisiteGuideCard), findsNothing);
      expect(find.text('Nenhuma ordem foi encontrada'), findsOneWidget);
    },
  );
}
