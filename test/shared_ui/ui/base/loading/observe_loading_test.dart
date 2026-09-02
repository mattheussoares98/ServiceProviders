import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_running.dart';

import '../../../../../testing/mocks/client_mocks.dart';

enum TestSectionKey implements SectionKey { details, comments }

class TestState extends BaseState {
  const TestState({super.sections = const {}});

  TestState copyWith({Map<SectionKey, SectionState>? sections}) {
    return TestState(sections: sections ?? this.sections);
  }
}

class TestCubit extends BaseCubit<TestState> {
  TestCubit([super.initialState = const TestState()]);

  void setSectionStatus(SectionKey section, SectionStatus status) {
    final updated = Map<SectionKey, SectionState>.from(state.sections);
    updated[section] = SectionState(status: status);
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
    observeRunning(targets, message: message);
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
    test('section factory constructor monitors section status', () {
      final cubit = TestCubit(
        const TestState(
          sections: {TestSectionKey.details: SectionState.running()},
        ),
      );
      final target = ObservedLoadingTarget.section(
        cubit,
        TestSectionKey.details,
      );

      expect(target.isLoading, isTrue);
    });

    test('returns false when section status does not match', () {
      final cubit = TestCubit(
        const TestState(
          sections: {TestSectionKey.details: SectionState.success()},
        ),
      );
      final target = ObservedLoadingTarget.section(
        cubit,
        TestSectionKey.details,
      );

      expect(target.isLoading, isFalse);
    });

    test('monitors multiple sections independently', () {
      final cubit = TestCubit(
        const TestState(
          sections: {
            TestSectionKey.details: SectionState.idle(),
            TestSectionKey.comments: SectionState.running(),
          },
        ),
      );
      final target = ObservedLoadingTarget(
        cubit,
        sections: const {TestSectionKey.details, TestSectionKey.comments},
      );

      expect(target.isLoading, isTrue);
    });
  });

  group('observeLoading Hook Widget Tests', () {
    testWidgets('shows overlay when section status matches target', (
      tester,
    ) async {
      final cubit = TestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestObserverWidget(
              targets: [
                ObservedLoadingTarget.section(cubit, TestSectionKey.details),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AlertDialog), findsNothing);

      cubit.setSectionStatus(TestSectionKey.details, SectionStatus.running);
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);

      cubit.setSectionStatus(TestSectionKey.details, SectionStatus.success);
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
