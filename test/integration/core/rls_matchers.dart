import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

import 'integration_error.dart';

/// Postgres SQLSTATEs this catalogue asserts on.
abstract final class PgCode {
  /// RLS denial / insufficient privilege.
  static const rlsDenied = '42501';

  /// Foreign key violation.
  static const foreignKey = '23503';

  /// Unique violation.
  static const unique = '23505';

  /// Check constraint violation.
  static const check = '23514';

  /// Not-null violation.
  static const notNull = '23502';

  /// Undefined column.
  static const undefinedColumn = '42703';

  /// Raised by every `RAISE EXCEPTION` in this schema's triggers.
  static const raised = 'P0001';
}

/// Matches a [FailureState] carrying a specific Postgres error code.
///
/// Needed because a call through a data source never throws: `SupabaseHandler`
/// routes the exception into `ErrorHandler.execute`, which returns a
/// `FailureState` with the exception flattened into a string.
Matcher isPostgrestFailure(String code) => predicate<Object?>((state) {
  if (state is! FailureState<Object?>) return false;
  return IntegrationError.fromState(state).code == code;
}, 'a FailureState carrying Postgres code $code');

/// Asserts that an **insert** is denied by RLS.
///
/// An insert that no policy admits raises `42501`, so this is the strict form.
Future<void> expectRlsDeniesInsert(
  SupabaseDatabaseClient db, {
  required String table,
  required MapDynamic values,
}) async {
  await expectLater(
    () => db.insert(table: table, values: values),
    throwsA(
      predicate<Object>(
        (error) => IntegrationError.from(error).code == PgCode.rlsDenied,
        'PostgrestException 42501',
      ),
    ),
  );
}

/// Asserts that an **update** is denied by RLS, in either of its two shapes.
///
/// Deliberately asymmetric with [expectRlsDeniesInsert], because an UPDATE can
/// be refused in two different ways and only one of them raises:
///
/// * The policy's **USING** clause hides the row. `SupabaseDatabaseClientImpl`
///   issues `.update().filter().select()`, so an invisible row yields an empty
///   list — indistinguishable at the protocol level from "no row matched".
/// * The policy's **WITH CHECK** clause rejects the *new* row (for example a
///   column the identity may not set). This raises `42501`, exactly like a
///   denied insert.
///
/// Both count as a denial. Callers should still assert that the row holds its
/// original value, since only that distinguishes a denial from a no-op.
Future<void> expectRlsDeniesUpdate(
  SupabaseDatabaseClient db, {
  required String table,
  required String id,
  required MapDynamic values,
}) async {
  try {
    final result = await db.update(
      table: table,
      values: values,
      filters: [SupabaseFilter.eq('id', id)],
    );
    expect(
      result,
      isEmpty,
      reason:
          'an RLS-denied UPDATE returns zero rows rather than raising; '
          '$table/$id was updated when it should not have been',
    );
  } on Object catch (error) {
    if (error is TestFailure) rethrow;
    expect(
      IntegrationError.from(error).code,
      PgCode.rlsDenied,
      reason: 'a raising UPDATE denial must be a WITH CHECK 42501, not $error',
    );
  }
}

/// Asserts that a row exists but is invisible to [db]'s identity.
Future<void> expectRlsHidesRow(
  SupabaseDatabaseClient db, {
  required String table,
  required String id,
}) async {
  final row = await db.selectOne(
    table: table,
    filters: [SupabaseFilter.eq('id', id)],
  );
  expect(
    row,
    isNull,
    reason: '$table/$id must not be visible to this identity',
  );
}

/// Asserts that a column still holds [expected] — the confirmation half of
/// [expectRlsDeniesUpdate].
Future<void> expectUnchanged(
  SupabaseDatabaseClient db, {
  required String table,
  required String id,
  required String column,
  required Object? expected,
}) async {
  final row = await db.selectOne(
    table: table,
    columns: 'id, $column',
    filters: [SupabaseFilter.eq('id', id)],
  );
  expect(row?[column], expected, reason: '$table/$id.$column must be unchanged');
}
