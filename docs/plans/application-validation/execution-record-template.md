# Execution record template

Copy into this plan's `runs/<run-id>.md` during approved execution. This template is not an executed run.

## Run context

- Date/time/timezone; operator; commit/build; flavor/entrypoint.
- Confirmed environment/project reference; schema/function version; company aliases.
- Devices/OS/browser; connectivity profile; deterministic random seed/clock.
- Account aliases and verified effective roles (no passwords, tokens, or keys).
- Approved scope, active layer, step/phase, dependencies and blocked prerequisites.
- Commands/checks run and actual exit codes; expected/discovered/executed case counts.

## Case results

| Case ID | Actor / mode | Fixtures | Expected result | Actual result | PASS / FAIL / BLOCKED / NOT RUN / N/A | Evidence / defect |
|---|---|---|---|---|---|---|
| To fill during execution | | | | | NOT RUN | |

For persistence cases attach sanitized before/after API reads, row IDs, screenshot or recording, and restart/second-session evidence. Record retries individually. A skip is BLOCKED or NOT RUN with a reason; it is never PASS. Include external-delivery authorization and recipient alias where applicable.

## Defect template

- ID, title, severity (P0–P3), feature, suspected layer, owner/status.
- Build/environment, actual role, reproducibility count, fixture IDs.
- Minimal ordered reproduction steps; expected vs actual result.
- Sanitized UI/log/network/database evidence and timestamps.
- Impact: security/data integrity/core flow/secondary usability.
- Separate observed behavior from suspected cause; note any rule ambiguity.
- Fix approval/dependency, regression test to add, retest result/date.

## Cleanup and recovery

- Exact created/changed row and object IDs, original permission/profile values.
- Cleanup allowed strategy per table, attempted result, independent verification.
- Append-only retained test history, failed cleanup IDs, pending queue/upload items.
- Recovery ledger location and outstanding manual action; never discard unresolved entries.

## Phase sign-off

- Phase: to fill.
- Command/check, result, evidence path, and date: to fill.
- Acceptance criteria satisfied: yes/no; reason for any remaining blocker.
- Change the phase checkbox only after all required checks pass; update the index only when all phases in that step pass.
