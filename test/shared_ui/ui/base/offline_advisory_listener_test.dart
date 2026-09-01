import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_state.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/offline_advisory_listener.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/provider_offline_blocker.dart';

import '../../../../testing/mocks/client_mocks.dart';

class TestOfflineAdvisoryCubit extends BaseCubit<OfflineAdvisoryState>
    implements OfflineAdvisoryCubit {
  TestOfflineAdvisoryCubit([super.initialState = const OfflineAdvisoryState()]);

  bool retryCalled = false;

  void emitState(OfflineAdvisoryState newState) => emit(newState);

  @override
  void checkStartupOrResume() {}

  @override
  void checkProviderConnectivity({AppMode? activeMode}) {}

  @override
  Future<bool> retryConnection() async {
    retryCalled = true;
    return true;
  }

  @override
  void dismissAlert() => emit(state.copyWith(annulAdvisoryEvent: true));
}

void main() {
  late MockNavigationClient mockNavigationClient;
  late TestOfflineAdvisoryCubit cubit;

  setUpAll(() {
    mockNavigationClient = MockNavigationClient();
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);
  });

  tearDownAll(() async {
    await GetIt.I.reset();
  });

  setUp(() {
    cubit = TestOfflineAdvisoryCubit();
  });

  tearDown(() {
    cubit.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<OfflineAdvisoryCubit>.value(
        value: cubit,
        child: const OfflineAdvisoryListener(
          child: Scaffold(body: Text('Home Content')),
        ),
      ),
    );
  }

  testWidgets('renders child normally when not blocked', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    expect(find.text('Home Content'), findsOneWidget);
    expect(find.byType(ProviderOfflineBlocker), findsNothing);
  });

  testWidgets(
    'displays ProviderOfflineBlocker overlay when isProviderBlocked is true',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Home Content'), findsOneWidget);
      expect(find.byType(ProviderOfflineBlocker), findsNothing);

      cubit.emitState(
        const OfflineAdvisoryState(
          status: DataStatus.loaded,
          isProviderBlocked: true,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProviderOfflineBlocker), findsOneWidget);
      expect(find.text('Sem conexão com a internet'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      cubit.emitState(const OfflineAdvisoryState(status: DataStatus.loaded));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProviderOfflineBlocker), findsNothing);
      expect(find.text('Home Content'), findsOneWidget);
    },
  );

  testWidgets('tapping Tentar novamente calls retryConnection on cubit', (
    tester,
  ) async {
    cubit.emitState(
      const OfflineAdvisoryState(
        status: DataStatus.loaded,
        isProviderBlocked: true,
      ),
    );
    await tester.pumpWidget(buildTestWidget());

    expect(find.byType(ProviderOfflineBlocker), findsOneWidget);
    expect(cubit.retryCalled, isFalse);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();

    expect(cubit.retryCalled, isTrue);
  });
}
