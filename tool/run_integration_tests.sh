#!/usr/bin/env bash
# Runs the integration behaviour suite against the LIVE Supabase project.
#
# Two guards keep a bare `flutter test` away from production:
#   1. IntegrationRun.registerGuard() -> suites register zero tests without the
#      INTEGRATION_TESTS flag this script exports (tag exclusion cannot be used:
#      `flutter test` will not re-include a tag dart_test.yaml excludes).
#   2. IntegrationRun.assertEnabled() -> backstop before any live connection.
#
# -j 1 is load-bearing: permission fixtures repoint a shared
# user_profiles.permission_group_id, so concurrent suites would clobber each other.
set -uo pipefail

cd "$(dirname "$0")/.."

REPORT_DIR="build/integration_report"
rm -rf "$REPORT_DIR"
mkdir -p "$REPORT_DIR"

export INTEGRATION_TESTS=true

TARGET="${1:-test/integration/tests}"

flutter test "$TARGET" \
  -j 1 \
  --dart-define=INTEGRATION_TESTS=true \
  --reporter expanded
STATUS=$?

# The run is expected to complete even with failures; the report is the deliverable.
dart run tool/build_integration_report.dart || true

echo
echo "Integration run finished (flutter test exit=$STATUS)."
echo "Report: INTEGRATION_TEST_ERRORS.md"
exit 0
