import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/offline_advisory_listener.dart';

import '../../../../testing/mocks/client_mocks.dart';

void main() {
  late MockNavigationClient mockNavigationClient;
  late MockOfflineTracker mockOfflineTracker;
  late StreamController<OfflineAdvisoryEvent> alertStreamController;
  late OfflineAdvisoryCubit cubit;

  setUpAll(() {
    mockNavigationClient = MockNavigationClient();
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);
  });

  tearDownAll(() async {
    await GetIt.I.reset();
  });

  setUp(() {
    mockOfflineTracker = MockOfflineTracker();
    alertStreamController = StreamController<OfflineAdvisoryEvent>.broadcast();
    when(
      () => mockOfflineTracker.alertStream,
    ).thenAnswer((_) => alertStreamController.stream);
    when(
      () => mockOfflineTracker.checkStartupOrResumeStatus(),
    ).thenReturn(false);

    cubit = OfflineAdvisoryCubit(offlineTracker: mockOfflineTracker);
  });

  tearDown(() {
    cubit.close();
    alertStreamController.close();
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

  testWidgets('displays alert dialog when OfflineAdvisoryState has event', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    expect(find.text('Home Content'), findsOneWidget);
    expect(find.text('Aviso de Modo Offline'), findsNothing);

    const event = OfflineAdvisoryEvent(
      trigger: OfflineAdvisoryTrigger.action,
      offlineDuration: Duration(hours: 2),
      pendingMutationCount: 10,
      hasBreachedDuration: true,
      hasBreachedRequests: true,
    );

    alertStreamController.add(event);
    await pumpEventQueue();
    await tester.pumpAndSettle();

    expect(find.text('Aviso de Modo Offline'), findsOneWidget);
    expect(find.text('Entendi'), findsOneWidget);

    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    expect(cubit.state.shouldShowDialog, isFalse);
    expect(find.text('Aviso de Modo Offline'), findsNothing);
  });
}
