import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';

import '../../../../../testing/mocks/client_mocks.dart';

enum TestSectionKey implements SectionKey {
  details,
  comments,
}

class TestState extends BaseState {
  const TestState({
    super.status = StateStatus.initial,
    super.errorMessage,
    super.sections = const {},
  });

  TestState copyWith({
    StateStatus? status,
    Map<SectionKey, StateStatus>? sections,
  }) {
    return TestState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
    );
  }
}

class TestCubit extends BaseCubit<TestState> {
  TestCubit([super.initialState = const TestState()]);

  void setStatus(StateStatus status) => emit(state.copyWith(status: status));

  void setSectionStatus(SectionKey section, StateStatus status) {
    final updated = Map<SectionKey, StateStatus>.from(state.sections);
    updated[section] = status;
    emit(state.copyWith(sections: updated));
  }
}

class TestObserverWidget extends HookWidget {
  const TestObserverWidget({
    super.key,
    required this.targets,
    this.message = 'Aguarde',
  });

  final List<ObservedLoadingTarget> targets;
  final String message;

  @override
  Widget build(BuildContext context) {
    observeLoading(targets, message: message);
    return const SizedBox.shrink();
  }
}

void main() {
  late MockNavigationClient mockNavigationClient;

  setUp(() {
    mockNavigationClient = MockNavigationClient();
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);
  });

  tearDown(() {
    GetIt.I.unregister<NavigationClient>();
  });
  group('ObservedLoadingTarget Unit Tests', () {
    test('returns true when root status matches default loading status', () {
      final cubit = TestCubit(const TestState(status: StateStatus.loading));
      final target = ObservedLoadingTarget(cubit);

      expect(target.isLoading, isTrue);
    });

    test('returns false when root status does not match default loading status', () {
      final cubit = TestCubit();
      final target = ObservedLoadingTarget(cubit);

      expect(target.isLoading, isFalse);
    });

    test('returns true when custom statuses match', () {
      final cubit = TestCubit(const TestState(status: StateStatus.saving));
      final target = ObservedLoadingTarget(
        cubit,
        statuses: {StateStatus.saving, StateStatus.deleting},
      );

      expect(target.isLoading, isTrue);
    });

    test('section factory constructor monitors section status', () {
      final cubit = TestCubit(
        const TestState(
          sections: {TestSectionKey.details: StateStatus.saving},
        ),
      );
      final target = ObservedLoadingTarget.section(
        cubit,
        TestSectionKey.details,
        statuses: {StateStatus.saving},
      );

      expect(target.isLoading, isTrue);
    });

    test('returns false when section status does not match', () {
      final cubit = TestCubit(
        const TestState(
          sections: {TestSectionKey.details: StateStatus.loaded},
        ),
      );
      final target = ObservedLoadingTarget.section(
        cubit,
        TestSectionKey.details,
        statuses: {StateStatus.saving},
      );

      expect(target.isLoading, isFalse);
    });

    test('monitors multiple sections independently', () {
      final cubit = TestCubit(
        const TestState(
          sections: {
            TestSectionKey.details: StateStatus.initial,
            TestSectionKey.comments: StateStatus.deleting,
          },
        ),
      );
      final target = ObservedLoadingTarget(
        cubit,
        statuses: const {},
        sections: {
          TestSectionKey.details: {StateStatus.saving},
          TestSectionKey.comments: {StateStatus.deleting},
        },
      );

      expect(target.isLoading, isTrue);
    });
  });

  group('observeLoading Hook Widget Tests', () {
    testWidgets('shows overlay when target becomes loading and hides on completion', (
      tester,
    ) async {
      final cubit = TestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestObserverWidget(
              targets: [ObservedLoadingTarget(cubit)],
            ),
          ),
        ),
      );

      expect(find.byType(AlertDialog), findsNothing);

      cubit.setStatus(StateStatus.loading);
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Aguarde'), findsOneWidget);

      cubit.setStatus(StateStatus.loaded);
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows overlay when section status matches target', (
      tester,
    ) async {
      final cubit = TestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestObserverWidget(
              targets: [
                ObservedLoadingTarget.section(
                  cubit,
                  TestSectionKey.details,
                  statuses: {StateStatus.saving},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AlertDialog), findsNothing);

      cubit.setSectionStatus(TestSectionKey.details, StateStatus.saving);
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);

      cubit.setSectionStatus(TestSectionKey.details, StateStatus.loaded);
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
