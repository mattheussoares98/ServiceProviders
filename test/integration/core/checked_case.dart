import 'package:flutter_test/flutter_test.dart';

import 'integration_error.dart';
import 'integration_report.dart';

/// Handle passed to a [checkedTest] body for recording what actually happened.
class CheckContext {
  CheckContext._(this.caseId);

  final String caseId;

  final List<String> _steps = [];
  final List<String> _notes = [];
  final List<String> _failures = [];
  String? _actual;
  String? _skipReason;
  IntegrationError? _error;
  StackTrace? _stack;

  /// Records a step as it is performed, so a failure report shows how far the
  /// case got rather than only where it stopped.
  void step(String description) => _steps.add(description);

  /// Records what was observed. Overwrites; call it with the decisive value.
  void actual(String value) => _actual = value;

  /// Records an aside — an unexpected-but-not-failing observation worth
  /// carrying into the report (this is how "record as a finding" cases report).
  void note(String value) => _notes.add(value);

  /// Marks the case unrunnable (a missing identity, an absent precondition).
  /// Recorded as SKIPPED, never as a pass.
  void skip(String reason) => _skipReason = reason;

  bool get isSkipped => _skipReason != null;

  /// An expectation that records its failure and **keeps going**.
  ///
  /// A catalogue case is a sequence of assertions over one scenario; with a bare
  /// `expect` a failure at step 3 hides whatever steps 4-7 would have revealed,
  /// which is exactly the information this pass exists to collect. Failures are
  /// aggregated and re-raised once, at the end of the case.
  void softExpect(Object? actual, Object? matcher, {String? reason}) {
    try {
      expect(actual, matcher, reason: reason);
    } on TestFailure catch (failure) {
      _failures.add(reason == null ? '$failure' : '$reason: $failure');
    }
  }

  /// Async variant of [softExpect] for a future under test.
  Future<void> softExpectLater(
    Object? actual,
    Object? matcher, {
    String? reason,
  }) async {
    try {
      await expectLater(actual, matcher, reason: reason);
    } on TestFailure catch (failure) {
      _failures.add(reason == null ? '$failure' : '$reason: $failure');
    }
  }

  /// Runs [body], recording any Supabase error it raises without failing the
  /// case — for steps whose failure is itself the observation.
  Future<void> tolerate(String label, Future<void> Function() body) async {
    try {
      await body();
    } on Object catch (error) {
      _notes.add('$label raised ${IntegrationError.from(error)}');
    }
  }
}

/// Registers one catalogue case.
///
/// Lives in `checked_case.dart`, not `checked_test.dart`: `flutter test`
/// collects every `*_test.dart` under `test/` as a suite, and a helper with no
/// `main()` fails the whole run.
///
/// Wraps `test()` so that whatever the outcome, a [CaseRecord] is written to
/// this suite's JSONL report before the result propagates. Failures are then
/// re-thrown, so `flutter test` still reports the run as red — the report is a
/// record of the run, not a way of hiding it.
///
/// The surrounding `test()` already isolates cases from one another, so a
/// failure here never stops the rest of the suite; [CheckContext.softExpect]
/// provides the same continuation *within* a single case.
void checkedTest(
  String id,
  String description, {
  required String feature,
  required Future<void> Function(CheckContext check) body,
  String? role,
  String layer = 'behaviour',
  String? expected,
  String suiteSlug = 'suite',
  Timeout? timeout,
}) {
  test('$id — $description', timeout: timeout, () async {
    final check = CheckContext._(id);
    final report = IntegrationReport.forSuite(suiteSlug);

    CaseOutcome outcome;
    Object? thrown;

    try {
      await body(check);
      if (check._failures.isNotEmpty) {
        throw TestFailure(check._failures.join('\n\n'));
      }
      outcome = check.isSkipped ? CaseOutcome.skipped : CaseOutcome.passed;
    } on Object catch (error, stackTrace) {
      thrown = error;
      outcome = check.isSkipped ? CaseOutcome.skipped : CaseOutcome.failed;
      check
        .._error = IntegrationError.from(error)
        .._stack = stackTrace;
    }

    report.record(
      CaseRecord(
        id: id,
        description: description,
        feature: feature,
        role: role,
        layer: layer,
        outcome: outcome,
        steps: check._steps,
        expected: expected,
        actual: check._actual ?? thrown?.toString(),
        notes: check._notes,
        error: outcome == CaseOutcome.failed ? check._error : null,
        stack: check._stack?.toString(),
        skipReason: check._skipReason,
      ),
    );

    // A skipped case is a recorded non-result, not a failure. The original
    // error is re-raised with its original stack so the console output stays
    // truthful about where the case actually broke.
    if (outcome == CaseOutcome.failed && thrown != null) {
      Error.throwWithStackTrace(thrown, check._stack ?? StackTrace.current);
    }
  });
}
