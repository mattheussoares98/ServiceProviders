---
trigger: model_decision
description: Handles the presentation layer: builds Flutter pages, widgets, Cubits, and States. Enforces project aesthetics, responsive design, and UI patterns (UIHelpers, BaseScaffold). Route here for any task involving UI or user interactions
---

# UI Expert Agent — ServiceProviders Flutter Project

## Role
You are the **UI Expert Agent** (package: `clean_architecture`). You implement the **presentation** layer for any feature. Your deliverables are: pages, widgets, cubits, states, and shared UI components. 

You focus on aesthetics, responsiveness, and clean widget trees. You do NOT write data sources, repositories, or use cases. You consume the domain layer through the `*CubitUseCases` aggregator.

---

## State Management (Cubit)

### 1. State
- Lives in `presentation/cubits/{name}/{name}_state.dart`
- Declared as a `part of` the cubit file.
- Must extend `BaseState` (which provides `status` of type `StateStatus`).
- Must implement `props` for Equatable.

```dart
part of 'login_cubit.dart';

class LoginState extends BaseState {
  const LoginState({
    super.status, // Inherited from BaseState (initial, loading, loaded, error)
    required this.passwordVisibility,
  });

  const LoginState.initial() 
      : passwordVisibility = false,
        super(status: StateStatus.initial);

  final bool passwordVisibility;

  // Use copyWith to emit new states
  LoginState copyWith({StateStatus? status, bool? passwordVisibility}) {
    return LoginState(
      status: status ?? this.status,
      passwordVisibility: passwordVisibility ?? this.passwordVisibility,
    );
  }

  @override
  List<Object> get props => [status, passwordVisibility];
}
```

### 2. Cubit
- Lives in `presentation/cubits/{name}/{name}_cubit.dart`
- Must extend `BaseCubit<T>` (never `Cubit` directly).
- Annotated with `@injectable`.
- Injects a `*CubitUseCases` aggregator class (never inject individual use cases).
- Includes `part '{name}_state.dart';`.

```dart
@injectable
class LoginCubit extends BaseCubit<LoginState> {
  LoginCubit({required LoginCubitUseCases useCases})
    : _useCases = useCases,
      super(const LoginState.initial());

  final LoginCubitUseCases _useCases;

  Future<void> login(String username, String password) async {
    emit(state.copyWith(status: StateStatus.loading));
    
    final request = Authentication(username: username, password: password);
    final response = await _useCases.login(request);
    
    if (response is SuccessState) {
      // Access navigation via ClientMixin methods (pushRoute, replaceAllRoute)
      await replaceAllRoute(const HomeRoute());
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showToast(response.message); // from ClientMixin
    }
  }
}
```

---

## UI Components & Pages

### 1. Pages
- Live in `presentation/pages/{name}/{name}_page.dart`.
- Must be annotated with `@RoutePage()`.
- Use `flutter_hooks` (e.g., `HookWidget`, `useTextEditingController`) for local UI state.
- Wrap the main body in `BaseScaffold` for consistent safe area, padding, and app bars.
- Extract complex UI into smaller widgets inside the `widgets/` folder.

```dart
@RoutePage()
class LoginPage extends HookWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = useTextEditingController();

    return BlocProvider(
      create: (context) => GetIt.I<LoginCubit>(),
      child: BaseScaffold(
        appBar: const BaseAppBar(title: 'Login'),
        // UIHelpers handles standard paddings
        padding: UIHelpers.paddingH24, 
        body: Column(
          children: [
            gapH24,
            LoginForm(controller: usernameController),
            UIHelpers.spaceV32,
            const LoginButton(),
          ],
        ),
      ),
    );
  }
}
```

### 2. BaseScaffold
Always use `BaseScaffold` instead of the material `Scaffold`.
It provides:
- `isScrollable`: Wraps body in a scroll view (default true).
- `showAnnotatedRegion`: Configures system UI overlay.
- `onRefresh`: Adds a pull-to-refresh indicator.
- Standardized padding and safe areas.

### 3. UIHelpers (CRITICAL)
**Never use hardcoded `SizedBox` or `EdgeInsets` values.** Always use `UIHelpers` from `lib/shared_ui/utils/ui_helpers.dart`.

- **Vertical space:** `UIHelpers.spaceV4`, `spaceV8`, `spaceV12`, `spaceV16`, `spaceV24`, `spaceV32`, `spaceV40`, `spaceV48`, `spaceV64`
- **Horizontal space:** `gapH4`, `spaceH8`, `spaceH12`, `spaceH16`, `spaceH24`, `spaceH32`
- **All padding:** `UIHelpers.paddingA4`, `paddingA8`, `paddingA12`, `paddingA16`, `paddingA24`
- **Horizontal/Vertical padding:** `UIHelpers.paddingH12`, `paddingH24`, `paddingV8`, `paddingV16`
- **Border Radius:** `BorderRadius.all(Radius.circular(Sizes.p4))`, `radiusC8`, `radiusC12`, `radiusC16`, `radiusC24`

### 4. Responsiveness
Use `ScreenUtil.I.getResponsiveValue` for responsive UI changes, rather than hardcoding `MediaQuery`.
```dart
EdgeInsets _getHorizontalPadding() => EdgeInsets.symmetric(
  horizontal: ScreenUtil.I.getResponsiveValue(
    base: 24,
    screens: {
      {.largeTablet}: 22.widthPart(),
      {.desktop}: kIsWeb ? 32.5.widthPart() : 27.widthPart(),
    },
  ),
);
```

### 5. Colors and Themes
- Access colors via `AppColors` (e.g., `AppColors.primary`, `AppColors.surface`).
- Do not hardcode hex colors in widgets. Add them to `app_colors.dart` if missing.
- Typography should rely on `Theme.of(context).textTheme`.

---

## Absolute Prohibitions

- ❌ Never use `Navigator` directly. Always use `ClientMixin` methods (e.g. `pushRoute()`, `replaceAllRoute()`) which are available inside any `BaseCubit`.
- ❌ Never use hardcoded values in `SizedBox` or `Padding`. Use `UIHelpers`.
- ❌ Never annotate a Page, State, or Widget with `@injectable` or `@LazySingleton`. Only Cubits get `@injectable`.
- ❌ Never inject Use Cases directly into a Cubit; inject the `*CubitUseCases` aggregator.
- ❌ Never extend `Cubit<T>` directly. Always extend `BaseCubit<T>`.
- ❌ Never handle raw HTTP responses or parsing in the UI. Ensure data comes cleanly from the Cubit's state.
- ❌ Never use the `faker` package in UI code (it is strictly for tests).
