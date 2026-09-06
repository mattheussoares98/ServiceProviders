import 'dart:convert';
import 'dart:io';

import 'integration_error.dart';

/// Outcome of a single catalogue case.
enum CaseOutcome {
  passed,
  failed,

  /// A precondition could not be provisioned (typically a missing identity).
  /// Recorded explicitly so it can never be mistaken for a pass.
  skipped,
}

/// One catalogue case's result, as written to the report.
class CaseRecord {
  CaseRecord({
    required this.id,
    required this.description,
    required this.feature,
    required this.outcome,
    this.role,
    this.layer = 'behaviour',
    this.steps = const [],
    this.expected,
    this.actual,
    this.notes = const [],
    this.error,
    this.stack,
    this.source,
    this.skipReason,
  });

  final String id;
  final String description;
  final String feature;
  final String? role;
  final String layer;
  final CaseOutcome outcome;
  final List<String> steps;
  final String? expected;
  final String? actual;
  final List<String> notes;
  final IntegrationError? error;
  final String? stack;
  final String? source;
  final String? skipReason;

  Map<String, Object?> toJson() => {
    'id': id,
    'description': description,
    'feature': feature,
    'outcome': outcome.name,
    if (role != null) 'role': role,
    'layer': layer,
    if (steps.isNotEmpty) 'steps': steps,
    if (expected != null) 'expected': expected,
    if (actual != null) 'actual': actual,
    if (notes.isNotEmpty) 'notes': notes,
    if (error != null) 'error': error!.toJson(),
    if (stack != null) 'stack': stack,
    if (source != null) 'source': source,
    if (skipReason != null) 'skipReason': skipReason,
  };
}

/// Append-only JSONL sink for case results.
///
/// One file **per suite**, named `${slug}-${pid}-${micros}.jsonl`. A single
/// shared file would not work: `flutter test` runs each test file in its own
/// isolate, so a singleton aggregates nothing, and concurrent appends from
/// several processes interleave into corrupt lines.
///
/// Every write is synchronous and flushed immediately, so a crash, a timeout, or
/// a `Ctrl-C` still leaves every completed case on disk — which is the whole
/// point of collecting failures rather than fixing them.
class IntegrationReport {
  IntegrationReport._(this._file);

  /// Returns the sink for [suiteSlug], creating the file on first use.
  factory IntegrationReport.forSuite(String suiteSlug) {
    return _open.putIfAbsent(suiteSlug, () {
      Directory(directory).createSync(recursive: true);
      final unique = DateTime.now().microsecondsSinceEpoch;
      final file = File('$directory/$suiteSlug-$pid-$unique.jsonl')
        ..createSync();
      return IntegrationReport._(file);
    });
  }

  static const String directory = 'build/integration_report';

  static final Map<String, IntegrationReport> _open = {};

  final File _file;

  /// Writes one record, flushing before returning.
  void record(CaseRecord record) {
    _file.writeAsStringSync(
      '${jsonEncode(record.toJson())}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}
