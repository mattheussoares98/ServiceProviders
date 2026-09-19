---
trigger: model_decision
description: File structure, layer boundaries, dependency injection, routing, and flavors
---

# Architecture

## Files and boundaries

Use `snake_case` filenames under `lib/features/<feature>/`:

| Directory | Contents |
|---|---|
| `data/data_sources/` | `<name>_remote_data_source.dart`, `<name>_local_data_source.dart`; interface + implementation together |
| `data/models/requests/`, `data/models/responses/` | DTOs |
| `data/repositories/` | `<name>_repository_impl.dart` |
| `domain/entities/`, `domain/repositories/`, `domain/use_cases/` | Entities, repository interfaces, use cases |
| `presentation/cubits/<cubit>/` | `<name>_cubit.dart`, `<name>_cubit_use_cases.dart`, `<name>_state.dart` |
| `presentation/pages/<name>/` | `<name>_page.dart` and page-local `widgets/` |
| `presentation/widgets/` | Feature-shared widgets |

Feature dependencies: data → domain; presentation → domain; domain imports neither feature data nor presentation. Shared project contracts such as `DataState` and type aliases are existing infrastructure exceptions, not permission to import feature implementations.

Use Mason (`mason make cubit_feature` / `mason make cubit_page`) only after inspecting the selected brick for current patterns and authorized scope. Existing bricks use legacy HTTP, omit the use-case aggregator, and generate incomplete state equality and duplicate safe areas; adapt output before accepting it, or author files from current contracts. Never generate multiple layers under single-layer approval. Prompts: `feature`, `cubit`, `page`.

Follow `analysis_options.yaml` (including package imports in `lib/`); do not disable lints to accommodate new code.

## DI

- App-lifetime objects: `@LazySingleton()` or `@LazySingleton(as: Interface)`.
- Cubits/new instances: `@injectable`; `*CubitUseCases`: `@LazySingleton()`.
- External packages: `@module` with `@lazySingleton` getters; async setup uses `@preResolve`.
- Flavor binding: `@LazySingleton(as: AppConfig, env: [Flavor.production])`.
- No DI annotations on pages, states, widgets, entities, or route guards.

## Routing

Add constants to `lib/routing/helper/route_data.dart`, register `AutoRoute(page: XRoute.page, path: kXPath)` in `lib/routing/routes.dart`, and annotate the page with `@RoutePage()`. Generated routes follow the shared generation rule.

Feature navigation goes through cubits and `ClientMixin` (`pushRoute`, `replaceAllRoute`, adaptive back/pop helpers). `replaceAllRoute` takes one route, not a list. Shared modal/dialog infrastructure may use `Navigator` to dismiss its own overlay. Guards in `lib/routing/guards/` are const `AutoRouteGuard` classes reading `GetIt` directly.

## Constants and flavors

Use `lib/core/constants/`: `api_endpoints.dart`, `app_colors.dart`, `app_icons.dart`, `local_storage_limits.dart`. Route constants belong in `route_data.dart`.

`Flavor` holds string constants; sealed `AppConfig` has `AppConfigProd`, `AppConfigStg`, `AppConfigDev`. Entry points: `main.dart`, `main_stg.dart`, `main_dev.dart`.

Never hardcode URLs: read `AppConfig.apiBaseUrl` / `webBaseUrl`. Environment mapping: `SUPABASE_URL` → `apiBaseUrl`, `SUPABASE_BASE_URL` → `webBaseUrl`; auth key: `SUPABASE_ANON_KEY`.
