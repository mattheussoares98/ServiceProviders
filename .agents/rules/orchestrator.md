---
trigger: always_on
---

# ServicePro project rules

Flutter CMMS (`o_jogo_da_obra`): Clean Architecture, Cubit, GetIt/injectable, auto_route, flutter_hooks; Supabase backend, Drift offline storage, R2 files, legacy Dio. Check `pubspec.yaml` for versions.

This is the project entry point. `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` only point here. User-wide preferences and planning rules remain in the user's global instructions.

## Load only relevant rules

Paths below are relative to `.agents/rules/`. Read once per task; reopen when changed or task scope expands.

| File | Read when touching |
|---|---|
| `architect.md` | Any production code change: boundaries, file structure, DI, routing, configuration |
| `feature.md` | Data sources, DTOs, repositories, entities, use cases |
| `ui.md` | Cubits, states, pages, widgets |
| `quality_assurance.md` | Behavior changes or validation, tests, and test helpers |
| `database.md` | Schema, migrations, RLS, Edge Functions |

Inspect relevant `.agents/skills/` entries when applicable; do not load every skill or reference document. Specialist files describe responsibilities, not a requirement to spawn agents.

## Workflow

1. Identify the authorized layer and relevant rules; honor the user's plan-only gate and layer boundaries. Split plans into concise per-layer files with phases. Tests, supporting docs, and plan progress accompany that layer.
2. Inspect current interfaces, callers, and relevant tests before editing. Preserve architecture review → implementation → QA within the authorized scope. Examples and existing violations do not override rules; flag material conflicts rather than inventing APIs.
3. Implement the authorized scope and run relevant checks. For behavior changes, update meaningful tests in the same turn; docs-only changes need no app tests. Report blocked validation accurately.
4. Review the final diff for requirements, regression risks, and unintended changes; preserve unrelated user edits. Follow the user's plan storage and completion rules; update phase checkboxes only after successful validation. Delete completed phases from plan files after finishing them; delete the plan file once all its phases are complete. Stop at any unapproved layer boundary.

## Quality and efficiency

Accuracy, completeness, and required validation take priority over token savings. Remove duplicated prose and stale examples, not safeguards or relevant investigation. Follow linked rule dependencies even when loading selectively. Report what changed, why, checks actually run, and material gaps; do not infer that a rule edit guarantees future agent behavior.

## Shared constraints

- App-visible strings are pt-BR; Dart literals use `.hardcoded`. This does not change the language of assistant replies.
- Never run `build_runner` or hand-edit generated files (`*.g.dart`, `routes.gr.dart`, `injector.config.dart`). Watch mode handles generation; report missing output if unavailable.
- Comments explain complex reasoning, not change history.
- DTOs use `MapDynamic`; serialize dates with `.toIsoUtcString()` and parse nullable JSON dates with `(json['x'] as String?).toUtcDateTime()`.
- Domain enums contain codes, not translated labels. Put `.label` getters in presentation extensions using `.hardcoded`.
- New permission-controlled resources must be registered in `ResourceType` and classified in `lib/features/users/domain/entities/permission/provider_mode_permission.dart`. Provider mode never inherits internal RBAC; keep that gate ahead of internal admin overrides. UI permission checks do not replace backend authorization.
- Maintain each rule in one owning file. Preserve explicit preferences unless changed by the user; distinguish intended conventions from existing violations. Update affected rules alongside approved API/pattern changes, except during plan-only tasks. Remove duplication only after checking that the replacement preserves scope, exceptions, and validation.

## Reference map

- `lib/features/<feature>/`: data, domain, presentation; `lib/core/`: clients, handlers, shared contracts/utilities.
- `lib/config/`: flavors and DI; `lib/routing/`: routes/guards; `lib/shared_ui/`: base widgets, cubits, themes.
- `docs/business_rules.md`: lifecycle/SLA/pause/completion; `docs/cmms/architecture.md`: data flow and sync.
- `docs/schema/index.md`: schema/ERD; `docs/database_rules/global_rules.md`: database policies.
