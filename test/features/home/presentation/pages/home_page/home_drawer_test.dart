import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/service_providers_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/home_drawer.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/themes/theme.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';
import 'package:patrol/patrol.dart';

import '../../../../../../testing/mocks/factories/user_factory.dart';
import 'home_page_test.dart';

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockCompanyCubit mockCompanyCubit;
  late MockSessionCubit mockSessionCubit;
  late MockUsersCubit mockUsersCubit;
  late MockModeSwitcherCubit mockModeSwitcherCubit;

  setUpAll(() {
    registerFallbackValue(
      const ActionPermission.resource(
        resourceType: ResourceType.users,
        permissionAction: PermissionAction.read,
      ),
    );
  });

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    mockCompanyCubit = MockCompanyCubit();
    mockSessionCubit = MockSessionCubit();
    mockUsersCubit = MockUsersCubit();
    mockModeSwitcherCubit = MockModeSwitcherCubit();

    when(() => mockHomeCubit.state).thenReturn(const HomeState.empty());
    when(() => mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());

    final userProfile = UserFactory.makeUserProfileEntity().copyWith(
      annulAvatarUrl: true,
      isAdmin: false,
    );
    when(
      () => mockSessionCubit.state,
    ).thenReturn(SessionState(user: userProfile, isLoggedIn: true));
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());

    when(
      () => mockUsersCubit.state,
    ).thenReturn(UsersState(users: [userProfile], permissionGroups: const []));
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.hasPermission(any())).thenReturn(false);

    when(
      () => mockModeSwitcherCubit.state,
    ).thenReturn(const ModeSwitcherState());
    when(
      () => mockModeSwitcherCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    const screenDetails = ScreenDetails(
      logicalSize: Size(1920, 1280),
      physicalSize: Size(1920, 1280),
      devicePixelRatio: 1,
    );
    ScreenUtil.I.configureScreen(screenDetails);
  });

  Widget buildTestWidget({required WorkType workType}) {
    final company = UserFactory.makeCompanyEntity().copyWith(
      workType: workType,
      annulLogoUrl: true,
    );
    when(
      () => mockCompanyCubit.state,
    ).thenReturn(CompanyState(company: company));
    when(() => mockCompanyCubit.stream).thenAnswer((_) => const Stream.empty());

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>.value(value: mockHomeCubit),
        BlocProvider<CompanyCubit>.value(value: mockCompanyCubit),
        BlocProvider<SessionCubit>.value(value: mockSessionCubit),
        BlocProvider<UsersCubit>.value(value: mockUsersCubit),
        BlocProvider<ModeSwitcherCubit>.value(value: mockModeSwitcherCubit),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: const Scaffold(
          drawer: HomeDrawer(),
          body: Center(child: Text('Home')),
        ),
      ),
    );
  }

  patrolWidgetTest(
    'shows ServiceProvidersDrawerItem when workType is internalOnly',
    ($) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await $.pumpWidget(buildTestWidget(workType: WorkType.internalOnly));
        await $.pumpAndSettle();

        $.tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
        await $.pumpAndSettle();

        expect($(ServiceProvidersDrawerItem), findsOneWidget);
        expect($('Prestadores de Serviço'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  patrolWidgetTest('shows ServiceProvidersDrawerItem when workType is hybrid', (
    $,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await $.pumpWidget(buildTestWidget(workType: WorkType.hybrid));
      await $.pumpAndSettle();

      $.tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await $.pumpAndSettle();

      expect($(ServiceProvidersDrawerItem), findsOneWidget);
      expect($('Prestadores de Serviço'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  patrolWidgetTest(
    'hides ServiceProvidersDrawerItem when workType is serviceProviderOnly',
    ($) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await $.pumpWidget(
          buildTestWidget(workType: WorkType.serviceProviderOnly),
        );
        await $.pumpAndSettle();

        $.tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
        await $.pumpAndSettle();

        expect($('Prestadores de Serviço'), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );
}
