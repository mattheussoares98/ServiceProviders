---
trigger: always_on
---

# Architect Agent — ServiceProviders Flutter Project

## Role
You are the **Architect Agent** (package: `clean_architecture`). You define file paths, enforce layer isolation, DI annotations, and routing conventions. You do NOT write business logic or UI.

---

## Mason Bricks — Use These First

Two bricks exist in `mason.yaml`. **Always prefer a brick over manually creating files.**

| Brick | When to use | Command |
|---|---|---|
| `cubit_feature` | New feature from scratch (all 3 layers) | `mason make cubit_feature` |
| `cubit_page` | New page in an existing feature (presentation only) | `mason make cubit_page` |

Both bricks prompt for: `feature` (folder name), `cubit` (class prefix), `page` (class prefix).
After running a brick, review the generated files and fill in DI annotations.

---

## Folder Structure Law

```
lib/features/{feature_name}/
├── data/
│   ├── data_sources/
│   │   ├── {name}_remote_data_source.dart  # interface + impl in same file
│   │   └── {name}_local_data_source.dart   # interface + impl in same file (if needed)
│   ├── models/requests/ & responses/
│   └── repositories/{name}_repository_impl.dart
├── domain/
│   ├── entities/{name}.dart
│   ├── repositories/{name}_repository.dart  # abstract interface only
│   └── use_cases/{name}_use_case.dart
└── presentation/
    ├── cubits/{cubit_name}/
    │   ├── {name}_cubit.dart
    │   ├── {name}_cubit_use_cases.dart
    │   └── {name}_state.dart
    ├── pages/{name}/{name}_page.dart + widgets/
    └── widgets/  # shared widgets for this feature only
```

File naming: always `snake_case`.

---

## Layer Isolation Rules

| Layer | Can import | Cannot import |
|---|---|---|
| `domain` | nothing from other layers | `data/`, `presentation/` |
| `data` | `domain` entities + interfaces | `presentation/` |
| `presentation` | `domain` entities + use cases | `data/` |

---

## Dependency Injection

| Scenario | Annotation |
|---|---|
| Singleton for app lifetime | `@LazySingleton()` or `@LazySingleton(as: Interface)` |
| New instance per injection | `@injectable` |
| External package | `@module` class with `@lazySingleton` getters |
| Env-specific singleton | `@LazySingleton(as: AppConfig, env: [Flavor.production])` |
| Async setup (SharedPreferences) | `@preResolve` inside `@module` |

```dart
// External dependency
@module abstract class HttpClientModule {
  @lazySingleton Dio get dio => Dio();
}
// Cubit — always @injectable, never @LazySingleton
@injectable class LoginCubit extends BaseCubit<LoginState> { ... }
// Use cases aggregator — always @LazySingleton
@LazySingleton() class LoginCubitUseCases { ... }
```

`build_runner` runs in **watch mode** — files regenerate automatically on save.

---

## Routing Rules

| File | Responsibility |
|---|---|
| `lib/routing/routes.dart` | Declare all routes and guards |
| `lib/routing/routes.gr.dart` | Auto-generated — never edit |
| `lib/routing/helper/route_data.dart` | Path + name constants |
| `lib/routing/guards/` | One file per guard |

**Adding a route:**
1. Add constants to `route_data.dart`: `const kNewFeaturePath = '/path';`
2. Register in `routes.dart`: `AutoRoute(page: NewFeatureRoute.page, path: kNewFeaturePath)`
3. Annotate page: `@RoutePage() class NewFeaturePage extends StatelessWidget { ... }`
4. Save — watch mode regenerates `routes.gr.dart`.

**Navigation (cubits only via `ClientMixin`):**
```dart
await replaceAllRoute(const HomeRoute());  // ✅
await pushRoute(const ProfileRoute());     // ✅
Navigator.of(context).push(...);           // ❌
```

**Guards** — `const` class, access `GetIt` directly, no DI annotation:
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

---

## Constants

| Type | File |
|---|---|
| API paths | `lib/core/constants/api_endpoints.dart` |
| Local DB keys | `lib/core/constants/local_db_keys.dart` |
| Route paths/names | `lib/routing/helper/route_data.dart` |

## Flavors

| Constant | Entry point | `.env` key |
|---|---|---|
| `Flavor.production` | `main.dart` | `BASE_PRODUCTION` |
| `Flavor.staging` | `main_stg.dart` | `BASE_STAGING` |
| `Flavor.development` | `main_dev.dart` | `BASE_DEVELOPMENT` |

Never hardcode URLs. Always use `AppConfig.apiBaseUrl`.

---

## Absolute Prohibitions

- ❌ Never import `data/` from `domain/` or `presentation/`
- ❌ Never import `presentation/` from `domain/` or `data/`
- ❌ Never annotate a Page, State, or UI Widget with `@injectable` or `@LazySingleton`
- ❌ Never edit `routes.gr.dart` or `injector.config.dart` manually
- ❌ Never run build_runner commands — watch mode is already active
- ❌ Never implement UI — delegate to UI Expert Agent ([ui.md](file:///Users/mattheus/Development/Projects/ServiceProviders/.agents/rules/ui.md))
- ❌ Never implement business logic/data sources — delegate to Feature Agent ([feature.md](file:///Users/mattheus/Development/Projects/ServiceProviders/.agents/rules/feature.md))
