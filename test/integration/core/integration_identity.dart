/// The distinct users an integration case can act as.
///
/// Each identity owns its own `SupabaseClient` (see `IntegrationSessions`), so a
/// single test file can drive several of them at once — which is what makes RLS
/// and scope-permission assertions possible at all.
enum Identity {
  /// Company admin from `INTEGRATION_TEST_ADMIN_*`. Holds `{"*": true}`.
  admin,

  /// Scoped technician from `INTEGRATION_TEST_TECH_*`.
  technician,

  /// The technician profile temporarily repointed at a throwaway group holding
  /// `work_orders.manage_pending_requests`, so both branches of every
  /// pause/completion business rule can be exercised by the same person.
  supervisor,

  /// Provider-mode identity: the technician's account resolved through its
  /// `service_provider_profiles` row, exactly as `ModeSwitcherCubit` does it.
  provider,

  /// A user of a *different* company, for cross-tenant denial cases. Optional —
  /// when it cannot be provisioned, dependent cases record as SKIPPED.
  foreign;

  /// Whether this identity is expected to exist in every environment.
  bool get isRequired => this != Identity.foreign;
}
