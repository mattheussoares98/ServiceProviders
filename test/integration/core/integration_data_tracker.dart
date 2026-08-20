/// Tracks IDs of all rows created during the current integration test run.
///
/// Singleton tracker that records IDs of entities created during `IntegrationCleanup`.
class IntegrationDataTracker {
  IntegrationDataTracker._();
  static final instance = IntegrationDataTracker._();

  final Map<String, List<String>> _created = {};

  /// Register a created row for later cleanup.
  void track(String table, String id) {
    _created.putIfAbsent(table, () => []).add(id);
  }

  /// Get all tracked IDs for a given table.
  List<String> getIds(String table) => _created[table] ?? [];

  /// Get all tracked tables and their IDs.
  Map<String, List<String>> get all => Map.unmodifiable(_created);

  /// Clear all tracked data (call after cleanup is done).
  void clear() => _created.clear();
}
