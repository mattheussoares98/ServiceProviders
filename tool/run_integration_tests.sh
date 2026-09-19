#!/usr/bin/env bash
# One guarded live test file per invocation. Preserve reports and recovery state.
set -uo pipefail
cd "$(dirname "$0")/.."
TARGET="${1:-}"
if [[ $# -ne 1 || ! -f "$TARGET" || "$TARGET" != test/integration/tests/*_test.dart ]]; then
  echo 'Provide exactly one test/integration/tests/*_test.dart file.' >&2
  exit 64
fi
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
export INTEGRATION_REPORT_DIR="build/integration_report/$RUN_ID"
mkdir -p "$INTEGRATION_REPORT_DIR"
export INTEGRATION_TESTS=true
flutter test "$TARGET" -j 1 --dart-define=INTEGRATION_TESTS=true \
  --machine > "$INTEGRATION_REPORT_DIR/runner.jsonl"
TEST_STATUS=$?
dart run tool/build_integration_report.dart
REPORT_STATUS=$?
echo "Flutter status: $TEST_STATUS; report status: $REPORT_STATUS"
if [[ $TEST_STATUS -ne 0 ]]; then exit "$TEST_STATUS"; fi
exit "$REPORT_STATUS"
