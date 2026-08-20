---
trigger: always_on
---

# Architect — ServicePro

Defines file paths, layer isolation, DI annotations, routing. Writes **no** business logic (→ `feature.md`) and **no** UI (→ `ui.md`).

## Mason Bricks — Prefer Over Manual Files
| Brick | When | Command |
|---|---|---|
| `cubit_feature` | New feature, all 3 layers | `mason make cubit_feature` |
| `cubit_page` | New page in existing feature | `mason make cubit_page` |

Both prompt for `feature` (folder), `cubit` (class prefix), `page` (class prefix). Review output and fill in DI annotations.

## Folder Law
```
lib/features/{feature}/
├── data/
│   ├── data_sources/{name}_remote_data_source.dart   # interface + impl, same file
│   │                {name}_local_data_source.dart    # interface + impl, same file
│   ├── models/requests/ & responses/
│   └── repositories/{name}_repository_impl.dart
├── domain/
│   ├── entities/{name}.dart
│   ├── repositories/{name}_repository.dart           # abstract interface only
│   └── use_cases/{name}_use_case.dart
└── presentation/
    ├── cubits/{cubit}/{name}_cubit.dart + _cubit_use_cases.dart + _state.dart
    ├── pages/{name}/{name}_page.dart + widgets/
    └── widgets/                                       # shared within this feature
```
Files: `snake_case`.

## Layer Isolation
| Layer | May import | Never imports |
|---|---|---|
| `domain` | nothing cross-layer | `data/`, `presentation/` |
| `data` | `domain` | `presentation/` |
| `presentation` | `domain` | `data/` |

## DI
| Case | Annotation |
|---|---|
| App-lifetime singleton | `@LazySingleton()` / `@LazySingleton(as: Interface)` |
| New instance each inject | `@injectable` |
| External package | `@module` class with `@lazySingleton` getters |
| Flavor-specific | `@LazySingleton(as: AppConfig, env: [Flavor.production])` |
| Async setup (SharedPreferences) | `@preResolve` in `@module` |

Cubits → always `@injectable`. `*CubitUseCases` → always `@LazySingleton()`. Pages/States/Widgets/Entities → **never** annotated.

## Routing
| File | Role |
|---|---|
| `lib/routing/routes.dart` | Routes + guards |
| `lib/routing/routes.gr.dart` | Generated — never edit |
| `lib/routing/helper/route_data.dart` | Path/name constants |
| `lib/routing/guards/` | One file per guard |

Add a route: constant in `route_data.dart` → `AutoRoute(page: XRoute.page, path: kXPath)` in `routes.dart` → `@RoutePage()` on the page → save (watch mode regenerates).

Navigate from cubits only, via `ClientMixin`: `pushRoute(...)`, `replaceAllRoute(...)`. Never `Navigator.of(context)`.

Guards are `const` classes reading `GetIt` directly, with no DI annotation:
```dart
final class AuthenticatedGuard extends AutoRouteGuard {
  const AuthenticatedGuard();
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (GetIt.I<SessionRepository>().isLoggedIn) return resolver.next();
    router.replaceAll([const LoginRoute()]);
  }
}
```

## Constants
| Type | File |
|---|---|
| API paths | `lib/core/constants/api_endpoints.dart` |
| Colors / icons | `lib/core/constants/app_colors.dart` / `app_icons.dart` |
| Storage limits | `lib/core/constants/local_storage_limits.dart` |
| Route paths/names | `lib/routing/helper/route_data.dart` |

## Flavors
`Flavor` is a `String` constant holder; `AppConfig` is a sealed class with one subclass per flavor.

| Flavor | Entry point | Config class |
|---|---|---|
| `Flavor.production` | `main.dart` | `AppConfigProd` |
| `Flavor.staging` | `main_stg.dart` | `AppConfigStg` |
| `Flavor.development` | `main_dev.dart` | `AppConfigDev` |

`.env` keys: `SUPABASE_URL` (→ `apiBaseUrl`), `SUPABASE_BASE_URL` (→ `webBaseUrl`), `SUPABASE_ANON_KEY`.
Never hardcode a URL — read `AppConfig.apiBaseUrl` / `AppConfig.webBaseUrl`.

## Prohibitions
- ❌ Cross-layer imports violating the table above
- ❌ DI annotations on Pages, States, Widgets, Entities
- ❌ Editing `routes.gr.dart` or `injector.config.dart` by hand
- ❌ Implementing UI or business logic here — delegate
