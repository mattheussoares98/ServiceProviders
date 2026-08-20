---
trigger: always_on
---

# Orchestrator — ServicePro

Flutter app, package `o_jogo_da_obra`. Decompose → delegate → validate → synthesize.

**This file is the single source of truth for global rules.** `/CLAUDE.md` and `/GEMINI.md` are thin pointers to it — never put a rule in either of them.

## Stack
Flutter (Dart ≥3.10) · Clean Architecture (data→domain→presentation) · Cubit/BLoC · GetIt+injectable · auto_route · flutter_hooks
**Supabase** (auth, Postgres, RLS, Edge Functions) · **Drift** (local SQLite) · **Cloudflare R2** (files) · Dio (legacy, 2 data sources) · Flavors: production/staging/development

## Folders
```
lib/
├── config/          # AppConfig (sealed, flavor-based), injector/
├── core/
│   ├── clients/
│   │   ├── local/   # AppDatabase (Drift), LocalStorageClient
│   │   └── remote/  # supabase/ (auth + database clients), storage/ (R2), http/, internet_client
│   ├── constants/   # api_endpoints, app_colors, app_icons, local_storage_limits
│   ├── data/        # handlers/ (RepositoryHandler, ErrorHandler, ApiHandler), models/, states/DataState
│   ├── domain/      # UseCase<T,P>, UseCaseNoParameter<T>
│   └── utils/       # type_defs.dart
├── features/{name}/ # data/ | domain/ | presentation/
├── routing/         # routes.dart, routes.gr.dart (generated), guards/, helper/
└── shared_ui/       # themes, base widgets, cubits/base, utils/
testing/mocks/       # EntityFactory + all mocks (repo root, NOT under test/)
```

## Specialists
| Rule file | Owns |
|---|---|
| `architect.md` | Layer isolation, DI, routing, file/folder naming |
| `feature.md` | Entities, use cases, repositories, data sources, DTOs |
| `ui.md` | Cubits, states, pages, widgets |
| `quality_assurance.md` | Unit + integration tests |
| `database.md` | Supabase schema, RLS, migrations, Edge Functions |

## Workflow
1. **Scope** — which layers? (data / domain / presentation / routing / config / db)
2. **Delegate** in order: Architect → Feature → UI → QA. Skip what doesn't apply.
3. **Verify** — no wrong-layer imports, DI annotations present, tests written and passing.

Tell each specialist exactly which files to create/modify, which classes to define, and which patterns to follow.

## Global Constraints — apply to every task
1. **pt-BR** for every user-visible string, wrapped in `.hardcoded`.
2. **Never run `build_runner`** — watch mode is active.
3. Comments explain *why*, only for complex logic. No change-marker comments.
4. DateTime: serialize with `.toIsoUtcString()`, parse with `(json['x'] as String?).toUtcDateTime()`.
5. `MapDynamic`, never `Map<String, dynamic>`, in DTOs.
6. New permission-controlled resource → register in `ResourceType` (`lib/features/users/domain/entities/permission.dart`).
7. Implementation and its test land in the same turn.
8. Never hardcode a URL — read `AppConfig.apiBaseUrl` / `AppConfig.webBaseUrl`.

## Reference Docs
`docs/business_rules.md` (domain lifecycle, SLA, pause/completion) · `docs/schema/index.md` (schema + ERD) · `docs/cmms/architecture.md` (data flow, sync state)

## Response Format
Start every response with a grammar/spelling correction of the user's message:
`Correction: [wrong] -> [correct] (reason)`. Omit the line entirely if there is nothing to correct.

## Rule Evolution
When a rule is agreed, wrong, or missing, update the relevant `.agents/rules/` file in the same turn. Keep rules compressed. Never duplicate a rule across files — shared rules belong here.
